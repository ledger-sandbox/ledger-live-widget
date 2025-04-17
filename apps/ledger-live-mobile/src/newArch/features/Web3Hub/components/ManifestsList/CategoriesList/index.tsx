import React, { useRef, useEffect } from "react";
import { FlashList } from "@shopify/flash-list";
import { Box } from "@ledgerhq/native-ui";
import { Category } from "LLM/features/Web3Hub/utils/api/categories";
import useCategoriesListViewModel, {
  type useCategoriesListViewModelProps,
} from "./useCategoriesListViewModel";
import Badge from "./Badge";

const identityFn = (item: Category) => item.id;

type Props = useCategoriesListViewModelProps;

const renderItem = ({
  item,
  extraData,
}: {
  item: Category;
  extraData?: useCategoriesListViewModelProps;
}) => {
  return (
    <Badge
      onPress={() => extraData?.selectCategory(item.id)}
      label={item.name}
      selected={extraData?.selectedCategory === item.id}
    />
  );
};

export default function CategoriesList({ selectedCategory, selectCategory }: Props) {
  const { data } = useCategoriesListViewModel({
    selectedCategory,
    selectCategory,
  });

  const flashListRef = useRef<FlashList<Category>>(null);

  useEffect(() => {
    if (selectedCategory) {
      const selectedIndex = data?.findIndex(category => category.id === selectedCategory);

      if (selectedIndex !== undefined && selectedIndex !== -1 && flashListRef.current) {
        setTimeout(() => {
          flashListRef.current?.scrollToIndex({
            index: selectedIndex,
            viewPosition: 0,
            animated: true,
          });
        }, 0);
      }
    }
  }, [selectedCategory, data]);

  return (
    <FlashList
      testID="web3hub-categories-scroll"
      horizontal
      keyExtractor={identityFn}
      renderItem={renderItem}
      ListEmptyComponent={<Box height={32} />}
      estimatedItemSize={50}
      data={data}
      showsHorizontalScrollIndicator={false}
      extraData={{ selectedCategory, selectCategory }}
      ref={flashListRef}
    />
  );
}
