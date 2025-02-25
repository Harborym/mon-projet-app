plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.app.ypm"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.app.ypm"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
        jvmTarget = "17"
        languageVersion = "1.9"
        apiVersion = "1.9"
        // Ajoute cet argument pour ignorer la vérification de la version des métadonnées :
        freeCompilerArgs += listOf("-Xskip-metadata-version-check")
    }
}

flutter {
    source = "../.."
}

dependencies {

    // Import the Firebase BoM

    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    implementation("com.google.firebase:firebase-auth")

    // TODO: Add the dependencies for Firebase products you want to use

    // When using the BoM, don't specify versions in Firebase dependencies

    implementation("com.google.firebase:firebase-analytics")
    implementation("org.apache.commons:commons-text:1.10.0")
    testImplementation("org.junit.jupiter:junit-jupiter-api:5.9.3")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.9.3")
    // Add the dependencies for any other desired Firebase products

    // https://firebase.google.com/docs/android/setup#available-libraries

}

tasks.withType<Test> {
    enabled = false
}

subprojects {
    tasks.withType<Test> {
        enabled = false
    }
}