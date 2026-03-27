package com.janus.omega

import android.os.Build
import android.os.Bundle
import android.os.StatFs
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import java.io.File

class HardwareFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View = inflater.inflate(R.layout.fragment_hardware, container, false)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val mfr = Build.MANUFACTURER.uppercase()
        val model = Build.MODEL.uppercase()
        view.findViewById<TextView>(R.id.tv_device).text = "  DEVICE:      $mfr $model"
        view.findViewById<TextView>(R.id.tv_android).text =
            "  ANDROID:     ${Build.VERSION.RELEASE}  (API ${Build.VERSION.SDK_INT})"
        view.findViewById<TextView>(R.id.tv_cpu).text =
            "  HARDWARE:    ${Build.HARDWARE.uppercase()}"
        view.findViewById<TextView>(R.id.tv_arch).text =
            "  ARCH:        ${Build.SUPPORTED_ABIS.firstOrNull() ?: "UNKNOWN"}"
        view.findViewById<TextView>(R.id.tv_board).text =
            "  BOARD:       ${Build.BOARD.uppercase()}"
        view.findViewById<TextView>(R.id.tv_kernel).text =
            "  KERNEL:      ${System.getProperty("os.version") ?: "UNKNOWN"}"

        val cores = Runtime.getRuntime().availableProcessors()
        view.findViewById<TextView>(R.id.tv_cores).text = "  CPU CORES:   $cores"

        val ram = getTotalRam()
        view.findViewById<TextView>(R.id.tv_ram).text = "  RAM:         $ram"

        val storage = getStorageInfo()
        view.findViewById<TextView>(R.id.tv_storage).text = "  STORAGE:     $storage"

        val fingerprint = Build.FINGERPRINT.take(40)
        view.findViewById<TextView>(R.id.tv_fingerprint).text = "  BUILD:       $fingerprint"
    }

    private fun getTotalRam(): String {
        return try {
            val reader = File("/proc/meminfo").bufferedReader()
            val line = reader.readLine()
            reader.close()
            val kb = line.replace("MemTotal:", "").replace("kB", "").trim().toLong()
            "${kb / 1024} MB"
        } catch (e: Exception) {
            "UNKNOWN"
        }
    }

    private fun getStorageInfo(): String {
        return try {
            val stat = StatFs(android.os.Environment.getDataDirectory().path)
            val total = stat.blockCountLong * stat.blockSizeLong / (1024 * 1024 * 1024)
            val free = stat.availableBlocksLong * stat.blockSizeLong / (1024 * 1024 * 1024)
            "${free}GB FREE / ${total}GB TOTAL"
        } catch (e: Exception) {
            "UNKNOWN"
        }
    }
}
