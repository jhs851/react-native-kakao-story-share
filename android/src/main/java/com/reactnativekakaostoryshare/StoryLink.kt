package com.reactnativekakaostoryshare

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.UnsupportedEncodingException
import java.net.URLEncoder
import java.nio.charset.Charset

/**
 * @author leoshin on 15. 10. 7.
 */
internal class StoryLink private constructor(private val context: Context) {
  private var params: String

  /**
   * Opens kakaoLink for parameter.
   *
   * @param activity Activity that will call startActivity()
   * @param params Params for KakaoLink
   */
  private fun openStoryLink(activity: Activity, params: String) {
    activity.startActivity(
      Intent(
        if (isAvailableIntent) Intent.ACTION_SEND else Intent.ACTION_VIEW,
        Uri.parse(params)
      )
    )
  }

  /**
   * Opens kakaoLink URL for parameters.
   *
   * @param activity Activity that will call startActivity()
   * @param url (message or url)
   * @param appId
   * your application ID
   * @param appVer
   * your application version
   * @param appName
   * your application name
   * @param encoding
   * recommend UTF-8
   * @param urlInfoAndroid URL info map object that will be transformed to json
   */
  fun openKakaoLink(activity: Activity, url: String, appId: String?, appVer: String?, appName: String?, encoding: String?, urlInfoAndroid: Map<String, Any>) {
    require(!(isEmptyString(url) || isEmptyString(appId) || isEmptyString(appVer) || isEmptyString(appName) || isEmptyString(encoding)))

    if (this.isAvailableIntent) {
      params = baseStoryLinkUrl
      appendParam("post", url)
      appendParam("appid", appId)
      appendParam("appver", appVer)
      appendParam("apiver", storyLinkApiVersion)
      appendParam("appname", appName)
      appendUrlInfo(urlInfoAndroid)
    } else {
      params = webStoryLinkUrl
      appendParam("url", url)
      appendParam("text", "${urlInfoAndroid.getValue("title")}-${urlInfoAndroid.getValue("desc")}")
    }

    openStoryLink(activity, params)
  }

  /**
   * @return Whether the application can open StoryLink URLs.
   */
  private val isAvailableIntent: Boolean
    get() {
      val kakaoLinkTestUri = Uri.parse(storyLinkURLBaseString)
      val intent = Intent(Intent.ACTION_SEND, kakaoLinkTestUri)
      val list = context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
      return list != null && list.isNotEmpty()
    }

  fun isEmptyString(str: String?): Boolean {
    return str == null || str.trim { it <= ' ' }.isEmpty()
  }

  private fun appendParam(name: String, value: String?) {
    try {
      val encodedValue = URLEncoder.encode(value, storyLinkEncoding)
      params = "$params$name=$encodedValue&"
    } catch (e: UnsupportedEncodingException) {
      e.printStackTrace()
    }
  }

  private fun appendUrlInfo(urlInfoAndroid: Map<String, Any>) {
    params += "urlinfo="
    val metaObj = JSONObject()
    try {
      for (key in urlInfoAndroid.keys) {
        if ("imageurl" == key) {
          metaObj.put(key, getImageUrl(urlInfoAndroid[key]))
        } else {
          metaObj.put(key, urlInfoAndroid[key])
        }
      }
    } catch (e: JSONException) {
      e.printStackTrace()
    }
    try {
      val encodedValue = URLEncoder.encode(metaObj.toString(), storyLinkEncoding)
      params += encodedValue
    } catch (e: UnsupportedEncodingException) {
      e.printStackTrace()
    }
  }

  private fun getImageUrl(imageUrl: Any?): JSONArray {
    val arrImageUrl = JSONArray()
    val objImageUrl = imageUrl as Array<*>?
    for (anObjImageUrl in objImageUrl!!) {
      arrImageUrl.put(anObjImageUrl)
    }
    return arrImageUrl
  }

  private val baseStoryLinkUrl: String
    get() = "$storyLinkURLBaseString?"

  private val webStoryLinkUrl: String
    get() = "$webLinkURLBaseString?"

  /**
   * Opens StoryLink for parameter.
   *
   * @param activity Activity that will call startActivity()
   * @param path Image path
   */
  fun openStoryLinkImageApp(activity: Activity, path: String?) {
    val intent = Intent(Intent.ACTION_SEND)
    intent.type = "image/png"
    intent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
    intent.setPackage("com.kakao.story")
    activity.startActivity(intent)
  }

  companion object {
    private const val storyLinkApiVersion = "1.0"
    private const val storyLinkURLBaseString = "storylink://posting"
    private const val webLinkURLBaseString = "https://story.kakao.com/s/share"
    private val storyLinkCharset = Charset.forName("UTF-8")
    private val storyLinkEncoding = storyLinkCharset.name()

    /**
     * Return the default singleton instance
     *
     * @param context Application context
     * @return StroyLink instance.
     */
    fun getLink(context: Context): StoryLink {
      return StoryLink(context)
    }
  }

  init {
    params = baseStoryLinkUrl
  }
}
