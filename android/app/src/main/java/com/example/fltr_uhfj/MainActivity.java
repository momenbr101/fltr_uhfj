package com.example.fltr_uhfj;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PersistableBundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;
import androidx.annotation.NonNull;

import java.util.HashMap;
import android.media.AudioManager;
import android.media.SoundPool;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.rscja.deviceapi.RFIDWithUHF;
import com.rscja.utility.StringUtility;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "demo.uhf/scan";
    private boolean loopFlag = false;
    public RFIDWithUHF mReader;
    Handler handler;
    MethodChannel custChannel;
    private String currTag = "";

    HashMap<Integer, Integer> soundMap = new HashMap<Integer, Integer>();
    private SoundPool soundPool;
    private float volumnRatio;
    private AudioManager am;

    private void initSound() {
        soundPool = new SoundPool(10, AudioManager.STREAM_MUSIC, 5);
        soundMap.put(1, soundPool.load(this, R.raw.barcodebeep, 1));
        soundMap.put(2, soundPool.load(this, R.raw.serror, 1));
        am = (AudioManager) this.getSystemService(AUDIO_SERVICE);// 实例化AudioManager对象
    }

    public void playSound(int id, float rssi_factor ) {

        float audioMaxVolumn = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        float audioCurrentVolumn = am.getStreamVolume(AudioManager.STREAM_MUSIC);
        volumnRatio = (audioCurrentVolumn / audioMaxVolumn) * rssi_factor;
        try {
            soundPool.play(soundMap.get(id), volumnRatio, // 左声道音量
                    volumnRatio, // 右声道音量
                    1, // 优先级，0为最低
                    0, // 循环次数，0无不循环，-1无永远循环
                    1 // 回放速度 ，该值在0.5-2.0之间，1为正常速度
            );
        } catch (Exception e) {
            e.printStackTrace();

        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        try {
            mReader = RFIDWithUHF.getInstance();
        }
        catch (Exception ex) {
            toastMessage(ex.getMessage());
            return;
        }
        if (mReader != null) {
            new InitTask().execute();
        }

        initSound();

        custChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

        handler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                String result = msg.obj + "";
                String[] strs = result.split("@");
                //addEPCToList(strs[0], strs[1]);
                //private void addEPCToList(String epc, String rssi)
                float rssi_factor = (70 + Float.parseFloat(strs[1])) / 70 ;
                playSound(1, rssi_factor);
                custChannel.invokeMethod("TAG_FOUND",result);
            }
        };

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("INIT")) {
                        result.success(mReader.toString());
                    }
                    else if (call.method.equals("READ_SINGLE")) {
                        result.success(readTag());
                    }
                    else if (call.method.equals("START_SCAN")) {
                        mReader.startInventoryTag(0,0);
                        loopFlag=true;
                        new TagThread().start();
                        result.success(true);
                    }
                    else if (call.method.equals("START_DETECT")) {
                        setCurrTag(call.arguments.toString());
                        toastMessage(call.arguments.toString());
                        mReader.startInventoryTag(0,0);
                        loopFlag=true;
                        new TagThread().start();
                        // playSound(1);
                        result.success(true);
                    }
                    else if (call.method.equals("STOP_SCAN")) {
                        stopInventory();
                        result.success(true);
                    }
                    else if (call.method.equals("VERSION") ) {
                        result.success(getUHFVersion());
                    }
                }
            );
    }

    @Override
    public void onPause() {
        Log.i("FLTR_UHFJ", "UHFReadTagFragment.onPause");
        super.onPause();

        // 停止识别
        stopInventory();
    }

    public void toastMessage(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    private void stopInventory() {
        if (loopFlag) {
            loopFlag = false;
            if (mReader.stopInventory()) {
                toastMessage("stopInventory");
            } else {
                toastMessage("Failed to stopInventory");
            }
        }
        setCurrTag("");
    }

    public String getCurrTag() {
        return currTag;
    }

    public void setCurrTag(String currTag) {
        this.currTag = currTag;
    }

    public class InitTask extends AsyncTask<String, Integer, Boolean> {
        ProgressDialog mypDialog;

        @Override
        protected Boolean doInBackground(String... params) {
            // TODO Auto-generated method stub
            return mReader.init();
        }

        @Override
        protected void onPostExecute(Boolean result) {
            super.onPostExecute(result);

            mypDialog.cancel();

            if (!result) {
                toastMessage("init fail");
            } else {
                // toastMessage("init success");
            }
        }

        @Override
        protected void onPreExecute() {
            // TODO Auto-generated method stub
            super.onPreExecute();

            mypDialog = new ProgressDialog(MainActivity.this);
            mypDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            mypDialog.setMessage("init...");
            mypDialog.setCanceledOnTouchOutside(false);
            mypDialog.show();
        }
    }

    @Override
    protected void onDestroy() {

        if (mReader != null) {
            mReader.free();
        }
        super.onDestroy();
    }


    public boolean vailHexInput(String str) {

        if (str == null || str.length() == 0) {
            return false;
        }

        if (str.length() % 2 == 0) {
            return StringUtility.isHexNumberRex(str);
        }

        return false;
    }

    private String getUHFVersion() {
        String version = "";
        if(mReader!=null) {

            version = mReader.getHardwareType();
            toastMessage("getUHFVersion : " + version);
        }
        return version;
    }

    class TagThread extends Thread {
        public void run() {
            String strTid;
            String strResult;
            String[] res = null;
            while (loopFlag) {
                res = mReader.readTagFromBuffer();
                if (res != null) {
                    strTid = res[0];
                    if (strTid.length() != 0 && !strTid.equals("0000000" +
                            "000000000") && !strTid.equals("000000000000000000000000")) {
                        strResult = "TID:" + strTid + "\n";
                    } else {
                        strResult = "";
                    }
                    Log.i("data","EPC:"+res[1]+"|"+strResult);
                    Message msg = handler.obtainMessage();
                    //msg.obj = strResult + "EPC:" + mReader.convertUiiToEPC(res[1]) + "@" + res[2];
                    String tag = mReader.convertUiiToEPC(res[1]);
                    msg.obj =  tag + "@" + res[2];
                    if( currTag == null || currTag.isEmpty()){
                        handler.sendMessage(msg);
                    }
                    else if ( currTag.equals(tag) ){
                        float rssi_factor =  (70 + Float.parseFloat(res[2])) / 70 ;
                        if(rssi_factor > .35 ) handler.removeCallbacksAndMessages(null);
                        handler.sendMessageDelayed(msg,  (long) (( 1 - rssi_factor) * 200) );
                    }
                }
            }
        }
    }

    private String readTag() {
        toastMessage("READ Tag Started ! ");
        String strUII = mReader.inventorySingleTag();
        if (!TextUtils.isEmpty(strUII)) {
            String strEPC = mReader.convertUiiToEPC(strUII);
            toastMessage("READ Success: "+strEPC);
            return strEPC;
        } else {
            toastMessage("READ Failed");
        }
        return  "";
    }
}
