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
}

dependencies {




    implementation ("com.squareup.retrofit2:retrofit:2.9.0")
    implementation ("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.activity)
    implementation(libs.firebase.messaging)
    implementation(libs.firebase.firestore)
    implementation ("com.google.android.gms:play-services-auth:20.4.1")
    implementation ("com.google.android.gms:play-services-basement:18.1.0")

//    implementation(libs.constraintlayout)
//
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)

//    implementation("androidx.appcompat:appcompat:1.7.0")
//    implementation("com.google.android.material:material:1.9.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
//    implementation("junit:junit:4.13.2")
//    implementation("androidx.test.ext:junit:1.1.5")
//    implementation("androidx.test.espresso:espresso-core:3.5.1")

//    implementation(libs.sdp.android)
//    implementation(libs.ssp.android)

    implementation("com.makeramen:roundedimageview:2.3.0")




    implementation ("androidx.recyclerview:recyclerview:1.3.2")
    implementation(platform("com.google.firebase:firebase-bom:33.3.0"))
//    implementation("com.google.firebase:firebase-messaging:24.0.2")
//
//    implementation(libs.navigation.fragment)
//    implementation(libs.navigation.ui)

    implementation("com.google.firebase:firebase-analytics")
//    implementation("com.android.support:support-v4:28.0.0")
//    implementation("com.android.support:design:28.0.0")
    implementation ("com.google.firebase:firebase-auth-ktx") // Si necesitas autenticación
    implementation("com.google.firebase:firebase-database-ktx")
//    implementation ("com.google.firebase:firebase-core:21.0.0")
//    implementation ("com.android.support:cardview-v7:28.0.0")
//    implementation ("com.google.firebase:firebase-firestore-ktx")
//    implementation(libs.activity)

    implementation("androidx.multidex:multidex:2.0.1")

    //Retrofit
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-scalars:2.9.0")
}