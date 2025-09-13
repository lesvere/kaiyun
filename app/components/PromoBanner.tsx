import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme';

export const PromoBanner = () => (
    <View style={styles.promoBanner}>
        <View style={styles.promoBannerContent}>
            <Text style={styles.promoBannerTitle}>助威金球巨星</Text>
            <Text style={{fontSize: 20, fontWeight: '500', color: '#0d3b80'}}>投票瓜分百万奖池</Text>
            <Text style={{marginTop: 10, color: '#2b5cb2'}}>2025年9月6日 - 9月21日</Text>
        </View>
        <View style={styles.promoBannerDots}>
            <View style={[styles.dot, styles.activeDot]} />
            <View style={styles.dot} />
            <View style={styles.dot} />
            <View style={styles.dot} />
        </View>
    </View>
);

const styles = StyleSheet.create({
    promoBanner: {
        marginHorizontal: 12,
        padding: 16,
        borderRadius: 12,
        backgroundColor: '#eaf2ff', // simplified from gradient
        height: 150,
        justifyContent: 'center',
        alignItems: 'center',
        textAlign: 'center',
    },
    promoBannerContent: {
        alignItems: 'center',
    },
    promoBannerTitle: {
        fontSize: 20,
        color: '#0d3b80',
        fontWeight: '700',
        marginBottom: 4,
        zIndex: 1,
    },
    promoBannerDots: {
        position: 'absolute',
        bottom: 10,
        left: '50%',
        transform: [{translateX: -20}], // approximation
        flexDirection: 'row',
        gap: 5,
    },
    dot: {
        width: 6,
        height: 6,
        borderRadius: 3,
        backgroundColor: 'rgba(255, 255, 255, 0.5)',
    },
    activeDot: {
        backgroundColor: 'white',
    },
});
