package com.reactnativekakaostoryshare

import android.app.Activity
import com.facebook.react.bridge.*
import java.lang.Exception
import java.util.*

class KakaoStoryShareModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "KakaoStoryShare"
  }

  @ReactMethod
  fun post(options: ReadableMap, promise: Promise) {
    val storyLink: StoryLink = StoryLink.getLink(this.reactApplicationContext)
    val urlInfoAndroid: MutableMap<String, Any> = Hashtable(1)
    val title = options.getString("title") ?: ""
    val url = options.getString("url") ?: ""
    val desc = if (options.hasKey("desc")) options.getString("desc") ?: "" else ""
    val imageurl = if (options.hasKey("imageURLs")) options.getArray("imageURLs") else null

    try {
      require(!(storyLink.isEmptyString(url) || storyLink.isEmptyString(title)))
    } catch (e: Exception) {
      promise.reject("Title and url are required values.", e.message)
    }

    urlInfoAndroid["title"] = title
    urlInfoAndroid["desc"] = desc
    urlInfoAndroid["type"] = "article"
    if (imageurl != null) {
      urlInfoAndroid["imageurl"] = imageurl
    }

    try {
      val activity: Activity? = this.reactApplicationContext.currentActivity

      if (activity != null) {
        storyLink.openKakaoLink(activity,
          url,
          this.reactApplicationContext.packageName,
          "1.0",
          this.reactApplicationContext.applicationInfo.name,
          "UTF-8",
          urlInfoAndroid)
      }

      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("KAKAO_API", e.message)
    }
  }
}
