import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { XIcon } from './Icons';
import { colors } from '../theme';

export const AppBanner = () => (
    <View style={styles.appBanner}>
      <TouchableOpacity style={styles.appBannerClose}>
        <XIcon size={24} color="#c8c9cc" />
      </TouchableOpacity>
      <View style={styles.appBannerInfo}>
        <View style={styles.appBannerLogo}>
          <Text style={styles.appBannerLogoText}>K</Text>
        </View>
        <View style={styles.appBannerText}>
          <Text style={styles.appBannerTitle}>开云APP</Text>
          <Text style={styles.appBannerSubtitle}>真人娱乐, 体育投注, 电子游艺等尽在一手掌握</Text>
        </View>
      </View>
      <TouchableOpacity style={styles.appBannerButton}>
        <Text style={styles.appBannerButtonText}>立即下载</Text>
      </TouchableOpacity>
    </View>
  );

const styles = StyleSheet.create({
    appBanner: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingVertical: 8,
        paddingHorizontal: 12,
        backgroundColor: '#f7f8fa',
        borderBottomWidth: 1,
        borderBottomColor: colors.palette.kaiyun_border,
    },
    appBannerInfo: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
    },
    appBannerClose: {
        // In React Native, TouchableOpacity is used for buttons, so direct styling of properties like 'cursor' is not applicable.
        // The 'fontSize' and 'color' are applied to the Icon inside it.
    },
    appBannerLogo: {
        width: 40,
        height: 40,
        backgroundColor: colors.palette.kaiyun_primaryBlue,
        borderRadius: 8,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
    },
    appBannerLogoText: {
        color: 'white',
        fontWeight: 'bold',
        fontSize: 20,
    },
    appBannerText: {

    },
    appBannerTitle: {
        fontSize: 14,
        fontWeight: '500',
    },
    appBannerSubtitle: {
        fontSize: 12,
        color: colors.palette.kaiyun_textSecondary,
    },
    appBannerButton: {
        backgroundColor: colors.palette.kaiyun_primaryBlue,
        paddingVertical: 8,
        paddingHorizontal: 16,
        borderRadius: 20,
    },
    appBannerButtonText: {
        color: 'white',
        fontSize: 13,
        fontWeight: '500',
    }
});
