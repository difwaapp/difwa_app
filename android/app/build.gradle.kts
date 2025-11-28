plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.difmo.difwa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.difmo.difwa"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = 12
        versionName = "1.0.12"
    }

    signingConfigs {
        create("release") {
            storeFile = file("difwakeystore.jks")
            storePassword = "Difmo2024@"
            keyAlias = "upload"
            keyPassword = "Difmo2024@"
        }
    }

buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")

        // FIX: enable code shrinking when using shrinkResources
        isMinifyEnabled = true 

        // optional but recommended
        isShrinkResources = true

        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}

}

flutter {
    source = "../.."
}
