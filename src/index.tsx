import { NativeModules } from 'react-native';

export type KakaoStoryShareOptions = {
  appName: string;
  title: string;
  url: string;
  desc?: string;
  imageURL?: string;
};

type KakaoStoryShareType = {
  post(options: KakaoStoryShareOptions): Promise<void>;
};

const { KakaoStoryShare } = NativeModules;

export default KakaoStoryShare as KakaoStoryShareType;
