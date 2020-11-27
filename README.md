# react-native-kakao-story-share

React-Native Module for KakaoStory

## Installation

```sh
yarn add react-native-kakao-story-share

or

npm install react-native-kakao-story-share
```

## React Native Link

### RN >= 0.60

```sh
npx pod-install
```

### RN <= 0.59
react-native link 를 이용하시면 빠른 설치가 가능합니다. 

```sh
react-native link react-native-kakao-story-share
```

## Usage

```js
import KakaoStoryShare from "react-native-kakao-story-share";

// ...

KakaoStoryShare.post({
  appName: '카카오 스토리 공유',
  title: '(광해) 실제 역사적 진실은?',
  url: 'http://star.ohmynews.com/NWS_Web/OhmyStar/at_pg.aspx?CNTN_CD=A0001779183',
  desc: '(광해 왕이 된 남자)의 역사성 부족을 논하다.',
  imageURLs: ['http://m1.daumcdn.net/photo-media/201209/27/ohmynews/R_430x0_20120927141307222.jpg'],
});
```

### Options

```ts
type KakaoStoryShareOptions = {
  appName: string;
  title: string;
  url: string;
  desc?: string;
  imageURLs?: string[];
};
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
