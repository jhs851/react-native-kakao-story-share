import * as React from 'react';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import KakaoStoryShare from 'react-native-kakao-story-share';

export default function App() {
  const share = () => {
    KakaoStoryShare.post({
      appName: '카카오 스토리 공유',
      title: 'title',
      url: 'https://apps.apple.com/kr/app/%EC%B9%A0%ED%85%90/id1498707344',
      desc: 'description',
    })
      .then(() => {
        console.log('resolve');
      })
      .catch((error) => console.log(error));
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={share}>
        <Text>Kakao Story Share</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
