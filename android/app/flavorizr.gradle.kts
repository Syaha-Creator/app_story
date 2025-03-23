import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("free") {
            dimension = "flavor-type"
            applicationId = "com.syahrul.app_story.free"
            resValue(type = "string", name = "app_name", value = "MyApp Free")
            manifestPlaceholders = [mapsApiKey: localProperties['MAPS_API_KEY']]
        }
        create("paid") {
            dimension = "flavor-type"
            applicationId = "com.syahrul.app_story.paid"
            resValue(type = "string", name = "app_name", value = "MyApp Paid")
            manifestPlaceholders = [mapsApiKey: localProperties['MAPS_API_KEY']]
        }
    }
}