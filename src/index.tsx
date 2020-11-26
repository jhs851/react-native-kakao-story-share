import { NativeModules } from 'react-native';

export type KakaoStoryShareOptions = {
  title: string;
  url: string;
  desc?: string;
  imageURLs?: string[];
};

type KakaoStoryShareType = {
  post(options: KakaoStoryShareOptions): Promise<void>;
};

const { KakaoStoryShare } = NativeModules;

export default KakaoStoryShare as KakaoStoryShareType;
