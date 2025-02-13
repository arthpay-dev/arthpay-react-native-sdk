import {
  requireNativeComponent,
  UIManager,
  Platform,
  type ViewStyle,
} from 'react-native';

import { ArthPayMerchant } from './ArthpayComponent/ArthPayMerchant';
import { OrderModel } from './ArthpayComponent/OrderModel';
import { CustomerModel } from './ArthpayComponent/CustomerModel';
import { CreateOrderRequest } from './ArthpayComponent/CreateOrderRequest';
const LINKING_ERROR =
  `The package 'arthpay-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type ArthpaySdkProps = {
  source: string; // The URL to load
  style?: ViewStyle; // Optional styles
};

const ComponentName = 'ArthpaySdkView';

export const ArthpaySdkView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<ArthpaySdkProps>(ComponentName)
    : () => {
      throw new Error(LINKING_ERROR);
    };
export {ArthPayMerchant,OrderModel,CustomerModel,CreateOrderRequest}


