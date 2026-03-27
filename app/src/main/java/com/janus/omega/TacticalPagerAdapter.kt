package com.janus.omega

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class TacticalPagerAdapter(activity: FragmentActivity) : FragmentStateAdapter(activity) {
    override fun getItemCount() = 3
    override fun createFragment(position: Int): Fragment = when (position) {
        0 -> DashboardFragment()
        1 -> OpsFragment()
        2 -> HardwareFragment()
        else -> DashboardFragment()
    }
}
