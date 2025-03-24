import com.android.build.gradle.AppExtension
import java.io.FileInputStream
import java.util.Properties

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("free") {
            dimension = "flavor-type"
            applicationId = "com.syahrul.app_story.free"
            resValue("string", "app_name", "MyApp Free")
            manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY")
        }
        create("paid") {
            dimension = "flavor-type"
            applicationId = "com.syahrul.app_story.paid"
            resValue("string", "app_name", "MyApp Paid")
            manifestPlaceholders["mapsApiKey"] = localProperties.getProperty("MAPS_API_KEY")
        }
    }
}
