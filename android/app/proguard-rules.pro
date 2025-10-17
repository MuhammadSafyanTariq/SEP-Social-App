#############################
# Flutter & Plugin Support #
#############################

# Keep Flutter plugin registrants
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Dart classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep annotated classes/methods used via reflection
-keepattributes *Annotation*
-keep @interface androidx.annotation.Keep
-keep @androidx.annotation.Keep class * { *; }
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
}

#####################
# Stripe SDK Fixes  #
#####################

# Stripe main SDK
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Suppress warnings for Stripe push provisioning module
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Required if Stripe uses Gson internally
-keep class com.google.gson.** { *; }
-keep class com.stripe.** { *; }
-dontwarn com.google.gson.**

########################
# Gson & Reflection    #
########################

-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; } # In case needed by dependencies

###################
# Agora (Optional) #
###################

# Uncomment if using Agora SDK
# -keep class io.agora.** { *; }
# -dontwarn io.agora.**

##########################
# Other Safe Defaults    #
##########################

# Avoid stripping inner classes used by reflection
-keepclassmembers class * {
    *;
}

# Keep enum values (used via name())
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Optional: Keep all public class/methods (only if you're facing obscure crashes)
# -keep public class * {
#    public *;
# }
