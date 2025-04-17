import React from "react";
import { useTranslation } from "react-i18next";
import { Flex, Icons, ScrollContainer, Text } from "@ledgerhq/native-ui";
import { Categories } from "@ledgerhq/live-common/wallet-api/react";

export function CatalogSection({
  categories: { categories, selected, setSelected },
}: {
  categories: Pick<Categories, "categories" | "selected" | "setSelected">;
}) {
  const { t } = useTranslation();

  const capitalizeFirstLetter = (string: string) => {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  return (
    <Flex backgroundColor="background.main" paddingY={3}>
      <ScrollContainer paddingLeft={16} horizontal showsHorizontalScrollIndicator={false}>
        {categories.map((value: string, index) => (
          <Flex
            key={index}
            marginRight={index === categories.length - 1 ? 8 : 4}
            bg={value === selected ? "opacityDefault.c05" : "transparent"}
            paddingX={4}
            paddingY={2}
            borderRadius="100px"
            flexDirection="row"
            alignItems="center"
            columnGap={8}
          >
            <Icons.LedgerLogo
              color={value === selected ? "primary.c80" : "opacityDefault.c70"}
              size="S"
            />
            <Text
              color={value === selected ? "primary.c80" : "opacityDefault.c70"}
              onPress={() => {
                setSelected(value);
              }}
              fontSize={15}
              fontWeight="semiBold"
              variant="body"
            >
              {value === "all"
                ? capitalizeFirstLetter(t("discover.sections.filter.all"))
                : capitalizeFirstLetter(value)}
            </Text>
          </Flex>
        ))}
      </ScrollContainer>
    </Flex>
  );
}
