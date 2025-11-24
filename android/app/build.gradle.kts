import java.util.Properties
import java.io.FileInputStream
plugins {



    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.app.sep"
//    compileSdk = flutter.compileSdkVersion
    compileSdk = 36
//    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.app.sep"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
        minSdk = 24
//        targetSdk = flutter.targetSdkVersion
        targetSdk = 36
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
        versionCode = 15
        versionName = "1.1.1"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false

//            isMinifyEnabled = true
//            isShrinkResources = true
//
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                file("proguard-rules.pro")
//            )

//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
//    implementation 'com.google.android.play:core:1.10.3'
}
