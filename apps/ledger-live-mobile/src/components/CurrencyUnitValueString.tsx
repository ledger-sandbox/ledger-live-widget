import { formatCurrencyUnit } from "@ledgerhq/coin-framework/lib/currencies/formatCurrencyUnit";
import { Unit } from "@ledgerhq/types-cryptoassets";
import BigNumber from "bignumber.js";

export const getCurrencyUnitFormattedString = ({
  unit,
  value,
  showCode = true,
  locale,
  discreet = false,
  before = "",
  after = "",
  alwaysShowValue = false,
  ...options
}: {
  unit: Unit;
  value: BigNumber | number;
  showCode?: boolean;
  locale: string;
  discreet?: boolean;
  before?: string;
  after?: string;
  alwaysShowValue?: boolean;
}) => {
  const val = value instanceof BigNumber ? value : new BigNumber(value);
  return (
    before +
    formatCurrencyUnit(unit, val, {
      showCode,
      locale,
      discreet: !alwaysShowValue && discreet,
      ...options,
    }) +
    after
  );
};
