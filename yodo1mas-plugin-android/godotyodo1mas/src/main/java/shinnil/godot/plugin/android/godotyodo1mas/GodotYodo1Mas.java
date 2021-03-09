package shinnil.godot.plugin.android.godotyodo1mas;

import android.app.Activity;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;

import com.yodo1.mas.Yodo1Mas;
import com.yodo1.mas.error.Yodo1MasError;
import com.yodo1.mas.event.Yodo1MasAdEvent;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Set;


public class GodotYodo1Mas extends GodotPlugin {
    private Activity activity = null; // The main activity of the game

    private boolean isReal = false; // Store if is real or not
    private boolean isForChildDirectedTreatment = false; // Store if is children directed treatment desired
    private boolean isPersonalized = true; // ads are personalized by default, GDPR compliance within the European Economic Area may require you to disable personalization.
    private String maxAdContentRating = ""; // Store maxAdContentRating ("G", "PG", "T" or "MA")
    private Bundle extras = null;

    private FrameLayout layout = null; // Store the layout

    public GodotYodo1Mas(Godot godot) {
        super(godot);
    }

    // create and add a new layout to Godot
    @Override
    public View onMainCreate(Activity activity) {
        layout = new FrameLayout(activity);
        this.activity = activity;
        Log.w("godot", "GodotYodo1Mas -> onMainCreate,  activity: " + activity.hashCode());
        return layout;
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "GodotYodo1Mas";
    }

    @NonNull
    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList(
                "init",
                // banner
//                "loadBanner", "showBanner", "hideBanner", "getBannerWidth", "getBannerHeight", "resize", "move",
                // Interstitial
                "showInterstitial",
                // Rewarded video
                "showRewardedVideo");
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();

        signals.add(new SignalInfo("on_interstitial_loaded"));
        signals.add(new SignalInfo("on_interstitial_failed_to_load", Integer.class));
        signals.add(new SignalInfo("on_interstitial_close"));


        signals.add(new SignalInfo("on_rewarded_video_ad_left_application"));
        signals.add(new SignalInfo("on_rewarded_video_ad_closed"));
        signals.add(new SignalInfo("on_rewarded_video_ad_failed_to_load", Integer.class));
        signals.add(new SignalInfo("on_rewarded_video_ad_loaded"));
        signals.add(new SignalInfo("on_rewarded_video_ad_opened"));
        signals.add(new SignalInfo("on_rewarded", String.class, Integer.class));
        signals.add(new SignalInfo("on_rewarded_video_started"));
        signals.add(new SignalInfo("on_rewarded_video_completed"));

        return signals;
    }

    /* Init
     * ********************************************************************** */

    /**
     * Prepare for work with AdMob
     *
     * @param appId  yodo1 application id
     */
    public void init(final String appId) {
        Yodo1Mas.getInstance().init(activity, appId, new Yodo1Mas.InitListener() {
            @Override
            public void onMasInitSuccessful() {
                Log.w("godot", "GodotYodo1Mas -> init successful");
            }

            @Override
            public void onMasInitFailed(@NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1Mas -> init failed, error: " + error.toString());

            }
        });

        initInterstitial();
        initRewardedVideo();
    }

    private void initInterstitial() {
        Yodo1Mas.getInstance().setInterstitialListener(new Yodo1Mas.InterstitialListener() {
            @Override
            public void onAdOpened(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1Mas Interstitial -> onAdOpened");
                emitSignal("on_interstitial_opened");
            }

            @Override
            public void onAdError(@NonNull Yodo1MasAdEvent event, @NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1Mas Interstitial -> onAdError " + error.toString());
                emitSignal("on_interstitial_failed_to_load", error.getCode());
            }

            @Override
            public void onAdClosed(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1Mas Interstitial -> onAdClosed");
                emitSignal("on_interstitial_close");
            }
        });
    }

    private void initRewardedVideo() {
        Yodo1Mas.getInstance().setRewardListener(new Yodo1Mas.RewardListener() {
            @Override
            public void onAdOpened(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1Mas RewardedVideo -> onAdOpened");
                emitSignal("on_rewarded_video_ad_opened");
            }

            @Override
            public void onAdvertRewardEarned(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1Mas RewardedVideo -> onAdvertRewardEarned");
                emitSignal("on_rewarded_video_completed");
            }

            @Override
            public void onAdError(@NonNull Yodo1MasAdEvent event, @NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1Mas RewardedVideo -> onAdError, error: " + error.toString());
                emitSignal("on_rewarded_video_ad_failed_to_load", error.getCode());
            }

            @Override
            public void onAdClosed(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1Mas RewardedVideo -> onAdClosed");
                emitSignal("on_rewarded_video_ad_closed");
            }
        });
    }

    /* Rewarded Video
     * ********************************************************************** */

    /**
     * Show a Rewarded Video
     */
    public void showRewardedVideo() {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isLoaded = Yodo1Mas.getInstance().isBannerAdLoaded();
                Log.w("godot", "GodotYodo1Mas RewardedVideo -> isLoaded = " + isLoaded);
                if(isLoaded) {
                    Yodo1Mas.getInstance().showRewardedAd(activity);
                }
            }
        });
    }


    /* Banner
     * ********************************************************************** */
//
//    /**
//     * Load a banner
//     *
//     * @param id      AdMod Banner ID
//     * @param isOnTop To made the banner top or bottom
//     */
//    public void loadBanner(final String id, final boolean isOnTop, final String bannerSize) {
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if (banner != null) banner.remove();
//                banner = new Banner(id, getAdRequest(), activity, new BannerListener() {
//                    @Override
//                    public void onBannerLoaded() {
//                        emitSignal("on_admob_ad_loaded");
//                    }
//
//                    @Override
//                    public void onBannerFailedToLoad(int errorCode) {
//                        emitSignal("on_admob_banner_failed_to_load", errorCode);
//                    }
//                }, isOnTop, layout, bannerSize);
//            }
//        });
//    }
//
//    /**
//     * Show the banner
//     */
//    public void showBanner() {
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if (banner != null) {
//                    banner.show();
//                }
//            }
//        });
//    }
//
//    /**
//     * Resize the banner
//     * @param isOnTop To made the banner top or bottom
//     */
//    public void move(final boolean isOnTop) {
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if (banner != null) {
//                    banner.move(isOnTop);
//                }
//            }
//        });
//    }
//
//    /**
//     * Resize the banner
//     */
//    public void resize() {
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if (banner != null) {
//                    banner.resize();
//                }
//            }
//        });
//    }
//
//
//    /**
//     * Hide the banner
//     */
//    public void hideBanner() {
//        activity.runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if (banner != null) {
//                    banner.hide();
//                }
//            }
//        });
//    }
//
//    /**
//     * Get the banner width
//     *
//     * @return int Banner width
//     */
//    public int getBannerWidth() {
//        if (banner != null) {
//            return banner.getWidth();
//        }
//        return 0;
//    }
//
//    /**
//     * Get the banner height
//     *
//     * @return int Banner height
//     */
//    public int getBannerHeight() {
//        if (banner != null) {
//            return banner.getHeight();
//        }
//        return 0;
//    }

    /* Interstitial
     * ********************************************************************** */

    /**
     * Show the interstitial
     */
    public void showInterstitial() {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isLoaded = Yodo1Mas.getInstance().isInterstitialAdLoaded();
                Log.w("godot", "GodotYodo1Mas Interstitial -> isLoaded = " + isLoaded);
                if(isLoaded) {
                    Yodo1Mas.getInstance().showInterstitialAd(activity);
                }
            }
        });
    }

    /* Utils
     * ********************************************************************** */

    /**
     * Get the Device ID for AdMob
     *
     * @return String Device ID
     */
    private String getAdMobDeviceId() {
        String android_id = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
        String deviceId = md5(android_id).toUpperCase(Locale.US);
        return deviceId;
    }

    /**
     * Generate MD5 for the deviceID
     *
     * @param s The string to generate de MD5
     * @return String The MD5 generated
     */
    private String md5(final String s) {
        try {
            // Create MD5 Hash
            MessageDigest digest = MessageDigest.getInstance("MD5");
            digest.update(s.getBytes());
            byte messageDigest[] = digest.digest();

            // Create Hex String
            StringBuffer hexString = new StringBuffer();
            for (int i = 0; i < messageDigest.length; i++) {
                String h = Integer.toHexString(0xFF & messageDigest[i]);
                while (h.length() < 2) h = "0" + h;
                hexString.append(h);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            //Logger.logStackTrace(TAG,e);
        }
        return "";
    }

}
