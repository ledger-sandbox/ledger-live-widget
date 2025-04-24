import { NativeModules } from "react-native";
const { WalletWidgetModule } = NativeModules;

export const updateWalletWidget = async ({
  price,
  percentage,
}: {
  price: string;
  percentage: number;
}) => {
  try {
    await WalletWidgetModule.updateWalletData(price, percentage);
  } catch (err) {
    console.error(err);
  }
};
