allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension> {
            defaultConfig {
                externalNativeBuild {
                    cmake {
                        arguments(
                            "-G", "Unix Makefiles",
                            "-DCMAKE_MAKE_PROGRAM=C:/Users/wang1/Documents/-TV/android/make_wrapper.bat"
                        )
                    }
                }
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
            defaultConfig {
                externalNativeBuild {
                    cmake {
                        arguments(
                            "-G", "Unix Makefiles",
                            "-DCMAKE_MAKE_PROGRAM=C:/Users/wang1/Documents/-TV/android/make_wrapper.bat"
                        )
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
