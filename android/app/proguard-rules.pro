# Flutter/plugin consumer rules are supplied by their dependencies.
# Preserve diagnostic source locations in release crash reports.
-keepattributes SourceFile,LineNumberTable

# Razorpay Flutter SDK documented release rules.
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
