import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme';

const cards = [
    { name: '开云体育', sub: 'KAIYUN SPORTS', games: 2714, tag1: '高达1.18%', tag2: '无限返水', hasBadge: true },
    { name: '熊猫体育', sub: 'PANDA SPORTS', games: 2347, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
    { name: 'IM体育', sub: 'IM SPORTS', games: 2046, tag1: '高达1.18%', tag2: '无限返水', hasBadge: false },
];

export const ContentCards = () => {
    return (
        <View style={styles.contentCards}>
            {cards.map(card => (
                 <View style={styles.contentCard} key={card.name}>
                    {card.hasBadge && <View style={styles.cardBadge}><Text style={styles.cardBadgeText}>✓ 官方认证</Text></View>}
                    <View style={styles.contentCardInfo}>
                        <Text style={styles.cardTitle}>{card.name}</Text>
                        <Text style={styles.cardSub}>{card.sub}</Text>
                        <Text style={styles.cardStats}>{card.games}<Text style={styles.cardStatsUnit}>场</Text></Text>
                        <View style={styles.contentCardTags}>
                            <Text style={styles.cardTag}>{card.tag1}</Text>
                            <Text style={[styles.cardTag, styles.cardTagBlue]}>{card.tag2}</Text>
                        </View>
                    </View>
                    <View style={styles.contentCardPlayers}>
                        <View style={[styles.playerPlaceholder, styles.player1]} />
                        <View style={[styles.playerPlaceholder, styles.player2]} />
                        <View style={[styles.playerPlaceholder, styles.player3]} />
                    </View>
                </View>
            ))}
        </View>
    );
};

const styles = StyleSheet.create({
    contentCards: {
        flexDirection: 'column',
        gap: 12,
        flexGrow: 1,
    },
    contentCard: {
        backgroundColor: colors.palette.kaiyun_cardBg,
        borderRadius: 12,
        padding: 16,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        position: 'relative',
        overflow: 'hidden',
        // boxShadow: '0 2px 12px rgba(0, 0, 0, 0.05)',
    },
    contentCardInfo: {},
    cardTitle: {
        fontSize: 16,
        fontWeight: '700',
    },
    cardSub: {
        fontSize: 12,
        color: colors.palette.kaiyun_textSecondary,
        textTransform: 'uppercase',
        marginTop: 2,
    },
    cardStats: {
        fontSize: 28,
        fontWeight: '700',
        marginVertical: 12,
    },
    cardStatsUnit: {
        fontSize: 14,
        fontWeight: '400',
        marginLeft: 4,
    },
    contentCardTags: {
        flexDirection: 'row',
        gap: 8,
    },
    cardTag: {
        fontSize: 11,
        paddingVertical: 4,
        paddingHorizontal: 8,
        borderRadius: 6,
        backgroundColor: '#eaf2ff',
        color: '#3a7fff',
        fontWeight: '500',
        overflow: 'hidden', // for borderRadius to work on <Text>
    },
    cardTagBlue: {
        backgroundColor: '#3a7fff',
        color: 'white',
    },
    cardBadge: {
        position: 'absolute',
        top: 0,
        left: -1,
        backgroundColor: '#eaf2ff',
        paddingVertical: 4,
        paddingHorizontal: 10,
        fontSize: 10,
        borderBottomRightRadius: 8,
    },
    cardBadgeText: {
        color: '#3a7fff',
        fontSize: 10,
    },
    contentCardPlayers: {
        width: 120,
        height: 100,
        position: 'relative',
        flexShrink: 0,
        marginRight: -16,
    },
    playerPlaceholder: {
        width: 60,
        height: 80,
        borderRadius: 8,
        backgroundColor: '#d0d8e8', // simplified gradient
        position: 'absolute',
        bottom: 0,
        borderWidth: 2,
        borderColor: 'white',
    },
    player1: {
        right: 50,
        zIndex: 3,
    },
    player2: {
        right: 25,
        zIndex: 2,
        transform: [{scale: 0.9}],
    },
    player3: {
        right: 0,
        zIndex: 1,
        transform: [{scale: 0.8}],
    },
});
