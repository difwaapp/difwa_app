plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.difmo.difwa"
    compileSdk = flutter.compileSdkVersion

    // REQUIRED FOR 16 KB SUPPORT
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.difmo.difwa"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = 34
        versionName = "1.0.34"

        // REQUIRED ABI SUPPORT FOR PLAY STORE
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }

        // REQUIRED FLAG FOR 16 KB PAGE SUPPORT
        externalNativeBuild {
            cmake {
                arguments += "-DANDROID_ARM64_USE_16K_PAGE_SIZE=ON"
            }
        }
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

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // REQUIRED TO SUPPORT 16 KB PAGE SIZE
    packaging {
        jniLibs.useLegacyPackaging = false
    }
}

flutter {
    source = "../.."
}
