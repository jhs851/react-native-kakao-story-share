import { NativeModules } from 'react-native';

type KakaoStoryShareType = {
  multiply(a: number, b: number): Promise<number>;
};

const { KakaoStoryShare } = NativeModules;

export default KakaoStoryShare as KakaoStoryShareType;
