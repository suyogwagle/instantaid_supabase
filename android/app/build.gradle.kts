plugins {
    id("com.android.application")
    id("kotlin-android")
    // id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.instant_aid"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.instant_aid"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    // implementation(platform("com.google.firebase:firebase-bom:32.2.2"))
    // implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}
