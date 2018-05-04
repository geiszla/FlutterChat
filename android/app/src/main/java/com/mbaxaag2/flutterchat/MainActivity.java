package com.mbaxaag2.flutterchat;

import android.annotation.TargetApi;
import android.os.Build;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.media.MediaRecorder;
import android.media.AudioRecord;
import android.media.AudioFormat;
import android.media.AudioTrack;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.List;

@TargetApi(Build.VERSION_CODES.CUR_DEVELOPMENT)
public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutterchat.mbaxaag2.com/audio";
  private static final String LOGTAG = "AudioRecorder";

  static AudioTrack audioTrack;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
          switch (methodCall.method) {
            case "recordAudio":
              final int length = methodCall.argument("length");
              record(length, result);
              break;
            case "playBytes":
              final List<Integer> bytes = methodCall.argument("bytes");
              final int samplingFrequency = methodCall.argument("samplingFrequency");

              short[] audioBytes = new short[bytes.size()];
              for (int i = 0; i < bytes.size(); i++) {
                audioBytes[i] = (short)bytes.get(i).intValue();
              }

              playBytes(audioBytes, samplingFrequency, result);
              break;
            case "pausePlayback":
              if (audioTrack != null && audioTrack.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                audioTrack.pause();
              }
              result.success(null);
              break;
            case "stopPlayback":
              if (audioTrack != null) {
                audioTrack.pause();
              }
              result.success(null);
              break;
            default:
              result.notImplemented();
          }
        }
      }
    );
  }

  private void record(int length, MethodChannel.Result result) {
    final int recordingLength = length;
    final MethodChannel.Result recordingResult = result;

    final int samplingFrequency = 8000;

    new Thread(new Runnable() {
      @Override
      public void run() {
        int sampleCount = samplingFrequency * recordingLength;

        short soundSamples[] = new short[sampleCount];
        int bufferSize = AudioRecord.getMinBufferSize(samplingFrequency, AudioFormat.CHANNEL_IN_MONO,
          AudioFormat.ENCODING_PCM_16BIT);
        int chunkCount = sampleCount / bufferSize;

        AudioRecord recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, samplingFrequency,
          AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, bufferSize * 2);

        int[] wavHeader = {0x46464952, 44 + sampleCount * 2, 0x45564157, 0x20746D66,16, 0x00010001,
          samplingFrequency, samplingFrequency * 2, 0x00100002, 0x61746164, sampleCount * 2};

        recorder.startRecording();
        for (int i = 0; i < chunkCount; i++) {
          recorder.read(soundSamples, i * bufferSize, bufferSize);
        }

        recorder.read(soundSamples, (chunkCount - 1) * bufferSize,
                sampleCount - (chunkCount - 1) * bufferSize);
        recorder.stop();
        Log.e(LOGTAG, "Finished recording");

        File tempDirectory = getApplicationContext().getCacheDir();
          final String filePath = tempDirectory + "/"
              + System.currentTimeMillis() + ".wav";

        try {
          File wavFile = new File(filePath);
          FileOutputStream wavOutputStream = new FileOutputStream(wavFile);
          DataOutputStream wavDataOutputStream = new DataOutputStream(wavOutputStream);

          for (int i = 0; i < wavHeader.length; i++) {
            wavDataOutputStream.writeInt(Integer.reverseBytes(wavHeader[i]));
          }

          for (int i = 0 ; i < soundSamples.length ; i++) {
            wavDataOutputStream.writeShort(Short.reverseBytes(soundSamples[i]));
          }

          wavOutputStream.close();
          Log.e(LOGTAG, "Wav file saved");
          recordingResult.success(filePath);
        } catch (IOException e) {
          Log.e(LOGTAG, "Wav file write error");
          recordingResult.error("ERROR", "Couldn't record audio.", null);
        }
      }
    }).start();
  }

  private void playBytes(short[] samples, int samplingFrequency, MethodChannel.Result result) {
    final short[] soundSamples = samples;
    final MethodChannel.Result playResult = result;

    final int sampleRate = samplingFrequency;

    new Thread(new Runnable() {
      @Override
      public void run() {
        int sampleCount = sampleRate * 10;

        audioTrack = new AudioTrack.Builder()
          .setTransferMode(AudioTrack.MODE_STREAM)
          .setAudioFormat(new AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(sampleRate)
            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
            .build())
          .setBufferSizeInBytes(sampleCount * 2)
          .build();


        for (int i = 15000; i < 15050; i++) {
          System.out.print(soundSamples[i] + ", ");
        }

        audioTrack.write(soundSamples, 0, sampleCount);
        audioTrack.play();

        while (audioTrack.getPlaybackHeadPosition() < sampleCount) {
//          if (audioTrack.getPlayState() != AudioTrack.PLAYSTATE_PLAYING) return;
//          System.out.println(audioTrack.getPlaybackHeadPosition()  + "/" + soundSamples.length);
        } //Wait before playing more

        audioTrack.stop();
        audioTrack.setPlaybackHeadPosition(0);

        while (audioTrack.getPlaybackHeadPosition() != 0) {} // wait for head position
        playResult.success(null);
      }
    }).start();
  }
}
