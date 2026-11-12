#!/usr/bin/env python3
"""Read-only live API check for ReadyLocal Partner. Run it yourself:

    python3 tool/api_check.py

It sends one OTP to that number, asks you to type it, then calls ONLY read
APIs with that partner's login and prints each result. It never accepts a job,
saves a transaction, withdraws or changes data. The token stays in memory.
"""
import json, sys, time, urllib.error, urllib.request

BASE = "https://njv1idkdb8.execute-api.ap-south-1.amazonaws.com/prod/"

def call(path, body=None, token=None):
    headers = {"Content-Type": "application/json", "Accept": "application/json", "User-Agent": "ReadyLocal-API-check"}
    if token:
        headers["Authorization"] = "Bearer " + token
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, headers=headers, method="GET" if body is None else "POST")
    start = time.time()
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            code, raw = r.status, r.read()
    except urllib.error.HTTPError as e:
        code, raw = e.code, e.read()
    except Exception as e:
        return "ERR", str(e), 0
    try:
        parsed = json.loads(raw)
    except ValueError:
        parsed = raw[:200].decode("utf8", "replace")
    return code, parsed, int((time.time() - start) * 1000)

def shape(value):
    if isinstance(value, list):
        return "list[%d] %s" % (len(value), shape(value[0]) if value else "")
    if isinstance(value, dict):
        return "{" + ", ".join(list(value.keys())[:12]) + "}"
    return type(value).__name__

def main():
    phone = sys.argv[1] if len(sys.argv) > 1 else input("Partner mobile number, with +91 (it will receive one OTP): ").strip()
    if not phone:
        sys.exit(__doc__)
    if not phone.startswith("+"):
        phone = "+91" + phone
    print("OTP request:", call("partnerOTP", {"MobileNumber": phone})[0])
    otp = input("OTP: ").strip()
    code, login, _ = call("partnerValidateOTP", {"MobileNumber": phone, "OTP": otp})
    if not isinstance(login, dict) or code != 200:
        sys.exit("Login failed: %s %s" % (code, login))
    data = login.get("Data") if isinstance(login.get("Data"), dict) else login
    partner = login.get("UserData") or data.get("UserData") or data.get("user") or data.get("User") or data.get("partner") or data
    token = (login.get("token") or login.get("Token") or login.get("jwtToken") or login.get("JWTToken")
             or data.get("token") or data.get("Token") or partner.get("token") or partner.get("Token"))
    pid = partner.get("_id") or partner.get("id") or partner.get("partnerId")
    print("Login response shape:", shape(login), "| data:", shape(data))
    print("Token found:", bool(token), "| Token field in:", [k for k in login if "oken" in k])
    if not token or not pid:
        sys.exit("No token or partner id found in the login response above.")

    results = []
    def run(label, path, body=None):
        code, parsed, ms = call(path, body, token)
        status = parsed.get("Status") if isinstance(parsed, dict) else None
        message = (parsed.get("Message") or parsed.get("message")) if isinstance(parsed, dict) else ""
        payload = parsed.get("Data", parsed) if isinstance(parsed, dict) else parsed
        ok = code == 200 and status != "FAILED"
        results.append(ok)
        print("%-4s %-26s %s %5dms %s %s %s" % ("OK" if ok else "FAIL", label, code, ms, status or "", message or "", shape(payload)))
        return payload

    modules = run("getModules", "getModules")
    # Catalogue data only: shows the exact field names the Select Service screen must read.
    print("     ^ getModules response:", json.dumps(modules)[:1500])
    fee = run("getRegistrationFees GET", "getRegistrationFees?partnerId=%s" % pid)
    print("     ^ registration fee response:", json.dumps(fee)[:300])
    run("getDriverServiceTypes", "getDriverServiceTypes")
    run("getVehicleTypes", "getVehicleTypes")
    run("getSafetySkills", "getSafetySkills")
    run("getDriverLicenseTypes", "getDriverLicenseTypes")
    for path in ["getPartnerDetails", "getEarningsSummary", "getEarningDetails", "listBankAccounts"]:
        run(path, path, {"partnerId": pid})
    for m in (modules if isinstance(modules, list) else []):
        mid = m.get("_id") or m.get("ModuleID") or m.get("moduleId")
        print("-- module", m.get("Name") or m.get("ModuleName") or mid)
        cats = run("getCategories", "getCategories", {"moduleID": mid})
        run("getServiceTypesNew", "getServiceTypesNew", {"moduleID": mid})
        if isinstance(cats, list) and cats:
            cid = cats[0].get("_id") or cats[0].get("CategoryID")
            subs = run("getSubCategoriesNew", "getSubCategoriesNew", {"categoryId": cid, "moduleID": mid})
            run("getPurohitServices", "getPurohitServices", {"categoryId": cid, "moduleID": mid})
            run("getPersonalCareServices", "getPersonalCareServices", {"categoryId": cid, "moduleID": mid})
            if isinstance(subs, list) and subs:
                run("getServicesNew", "getServicesNew", {"subCategoryId": subs[0].get("_id"), "moduleID": mid})
    print("\n%d of %d read APIs OK" % (sum(results), len(results)))

if __name__ == "__main__":
    main()
