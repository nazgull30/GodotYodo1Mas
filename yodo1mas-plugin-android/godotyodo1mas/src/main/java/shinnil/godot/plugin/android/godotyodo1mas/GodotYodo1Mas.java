package shinnil.godot.plugin.android.godotyodo1mas;

import android.app.Activity;
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

import java.util.Arrays;
import java.util.List;
import java.util.Set;


public class GodotYodo1Mas extends GodotPlugin {
    private Activity activity = null; // The main activity of the game

    public GodotYodo1Mas(Godot godot) {
        super(godot);
    }

    // create and add a new layout to Godot
    @Override
    public View onMainCreate(Activity activity) {
        FrameLayout layout = new FrameLayout(activity);
        this.activity = activity;
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
                "setGDPR",
                "setCCPA",
                "setCOPPA",

                "showBannerAd",
                "showBannerAdWithAlign",
                "showBannerAdWithAlignAndOffset",
                "dismissBannerAd",

                "isInterstitialAdLoaded",
                "showInterstitialAd",

                "isRewardedAdLoaded",
                "showRewardedAd");
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();

        signals.add(new SignalInfo("on_banner_ad_not_loaded"));
        signals.add(new SignalInfo("on_banner_ad_opened"));
        signals.add(new SignalInfo("on_banner_ad_closed"));
        signals.add(new SignalInfo("on_banner_ad_error", Integer.class));

        signals.add(new SignalInfo("on_interstitial_ad_not_loaded"));
        signals.add(new SignalInfo("on_interstitial_ad_opened"));
        signals.add(new SignalInfo("on_interstitial_ad_closed"));
        signals.add(new SignalInfo("on_interstitial_ad_error", Integer.class));

        signals.add(new SignalInfo("on_rewarded_ad_not_loaded"));
        signals.add(new SignalInfo("on_rewarded_ad_opened"));
        signals.add(new SignalInfo("on_rewarded_ad_closed"));
        signals.add(new SignalInfo("on_rewarded_ad_error", Integer.class));
        return signals;
    }

    /* Init
     * ********************************************************************** */

    public void setGDPR(boolean gdpr) {
        Yodo1Mas.getInstance().setGDPR(gdpr);
    }

    public void setCCPA(boolean ccpa) {
        Yodo1Mas.getInstance().setCCPA(ccpa);
    }

    public void setCOPPA(boolean coppa) {
        Yodo1Mas.getInstance().setCOPPA(coppa);
    }

    /**
     * Prepare for work with AdMob
     *
     * @param appId  yodo1 application id
     */
    public void init(final String appId) {
        initBannerAd();
        initInterstitialAd();
        initRewardedAd();

        Yodo1Mas.getInstance().init(activity, appId, new Yodo1Mas.InitListener() {
            @Override
            public void onMasInitSuccessful() {
                Log.w("godot", "GodotYodo1MasWrapper -> initialize successful");
            }

            @Override
            public void onMasInitFailed(@NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1MasWrapper -> initialize error: " + error.toString());
            }
        });
    }

    private void initBannerAd() {
        Yodo1Mas.getInstance().setBannerListener(new Yodo1Mas.BannerListener() {
            @Override
            public void onAdOpened(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdOpened");
                emitSignal("on_banner_ad_opened");
            }

            @Override
            public void onAdError(@NonNull Yodo1MasAdEvent event, @NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdError: " + error.getCode());
                emitSignal("on_banner_ad_error", error.getCode());
            }

            @Override
            public void onAdClosed(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdClosed");
                emitSignal("on_banner_ad_closed");
            }
        });
    }

    private void initInterstitialAd() {
        Yodo1Mas.getInstance().setInterstitialListener(new Yodo1Mas.InterstitialListener() {
            @Override
            public void onAdOpened(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdOpened");
                emitSignal("on_interstitial_ad_opened");
            }

            @Override
            public void onAdError(@NonNull Yodo1MasAdEvent event, @NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdError: " + error.toString());
                emitSignal("on_interstitial_ad_error", error.getCode());
            }

            @Override
            public void onAdClosed(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdClosed");
                emitSignal("on_interstitial_ad_closed");
            }
        });
    }

    private void initRewardedAd() {
        Yodo1Mas.getInstance().setRewardListener(new Yodo1Mas.RewardListener() {
            @Override
            public void onAdOpened(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdOpened");
                emitSignal("on_rewarded_ad_opened");
            }

            @Override
            public void onAdvertRewardEarned(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdRewardEarned");
                emitSignal("on_rewarded_ad_earned");
            }

            @Override
            public void onAdError(@NonNull Yodo1MasAdEvent event, @NonNull Yodo1MasError error) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdError: " + error.toString());
                emitSignal("on_rewarded_ad_error", error.getCode());
            }

            @Override
            public void onAdClosed(@NonNull Yodo1MasAdEvent event) {
                Log.w("godot", "GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdClosed");
                emitSignal("on_rewarded_ad_closed");
            }
        });
    }

    /* Banner
     * ********************************************************************** */

    public boolean isBannerAdLoaded() {
        return  Yodo1Mas.getInstance().isBannerAdLoaded();
    }

    public void showBannerAd() {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isBannerAdLoaded = isBannerAdLoaded();
                Log.w("godot", "GodotYodo1MasWrapper -> showBannerAd, isBannerAdLoaded: " + isBannerAdLoaded);
                if(!isBannerAdLoaded) {
                    emitSignal("on_banner_ad_not_loaded");
                    return;
                }

                Yodo1Mas.getInstance().showBannerAd(activity);
            }
        });
    }

    public void showBannerAdWithAlign(final int align) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isBannerAdLoaded = isBannerAdLoaded();
                Log.w("godot", "GodotYodo1MasWrapper -> showBannerAdWithAlign, isBannerAdLoaded: " + isBannerAdLoaded);
                if(!isBannerAdLoaded) {
                    emitSignal("on_banner_ad_not_loaded");
                    return;
                }

                Yodo1Mas.getInstance().showBannerAd(activity, align);
            }
        });
    }

    public void showBannerAdWithAlignAndOffset(final int align, final int offsetX, final int offsetY) {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isBannerAdLoaded = isBannerAdLoaded();
                Log.w("godot", "GodotYodo1MasWrapper -> showBannerAdWithAlignAndOffset, isBannerAdLoaded: " + isBannerAdLoaded);
                if(!isBannerAdLoaded) {
                    emitSignal("on_banner_ad_not_loaded");
                    return;
                }

                Yodo1Mas.getInstance().showBannerAd(activity, align, offsetX, offsetY);
            }
        });
    }

    /* Interstitial
     * ********************************************************************** */

    public boolean isInterstitialAdLoaded() {
        return  Yodo1Mas.getInstance().isInterstitialAdLoaded();
    }

    public void showInterstitial() {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isInterstitialAdLoaded = isInterstitialAdLoaded();
                Log.w("godot", "GodotYodo1MasWrapper isInterstitialAdLoaded: " + isInterstitialAdLoaded);
                if(!isInterstitialAdLoaded) {
                   emitSignal("on_interstitial_ad_not_loaded");
                   return;
                }

                Yodo1Mas.getInstance().showInterstitialAd(activity);
            }
        });
    }


    /* Rewarded Video
     * ********************************************************************** */


    public boolean isRewardedAdLoaded() {
        return  Yodo1Mas.getInstance().isBannerAdLoaded();
    }

    public void showRewardedAd() {
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                boolean isRewardedAdLoaded = isRewardedAdLoaded();
                Log.w("godot", "GodotYodo1MasWrapper isRewardedAdLoaded: " + isRewardedAdLoaded);
                if(!isRewardedAdLoaded) {
                    emitSignal("on_rewarded_ad_not_loaded");
                    return;
                }

                Yodo1Mas.getInstance().showRewardedAd(activity);
            }
        });
    }
}
