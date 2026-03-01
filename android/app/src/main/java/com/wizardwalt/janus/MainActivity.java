package com.wizardwalt.janus;

import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView tv = new TextView(this);
        tv.setText("JANUS Ω OS\nPip-Boy 3000 Online\n\nFLIP MODE");
        tv.setTextSize(24);
        tv.setTextColor(0xFF00FF41);
        setContentView(tv);
    }
}
