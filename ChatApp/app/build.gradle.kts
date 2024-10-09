import com.android.build.api.dsl.Packaging

plugins {
    alias(libs.plugins.android.application)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.pucmm.chatapp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.pucmm.chatapp"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    buildFeatures {
        viewBinding = true
    }

    fun Packaging.() {
        jniLibs.excludes.add("META-INF/DEPENDENCIES")
        jniLibs.excludes.add("META-INF/LICENSE")
        jniLibs.excludes.add("META-INF/LICENSE.txt")
        jniLibs.excludes.add("META-INF/NOTICE")
        jniLibs.excludes.add("META-INF/NOTICE.txt")
    }

}

dependencies {
    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.activity)

    // Firebase and Google Play Services
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-database-ktx")

//    implementation ("com.google.auth:google-auth-library-oauth2-http:1.15.0")
    // Google Play Services
//    implementation("com.google.android.gms:play-services-auth:20.4.1")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.retrofit2:converter-scalars:2.9.0")

    // OkHttp
    implementation("com.squareup.okhttp3:okhttp:4.9.1")
    implementation ("io.jsonwebtoken:jjwt:0.9.1")


    // Multidex
    implementation("androidx.multidex:multidex:2.0.1")

    // Other dependencies
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.makeramen:roundedimageview:2.3.0")

    // Test dependencies
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)

}