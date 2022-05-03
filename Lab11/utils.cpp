#include "utils.h"

uint32_t extract_tag(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t offset = cache_config.get_num_block_offset_bits();
  uint32_t index = cache_config.get_num_index_bits();
  uint32_t tag = cache_config.get_num_tag_bits();

  if (tag > 31) {
    return address;
  }
  return (address >> (offset + index));
}

uint32_t extract_index(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t offset = cache_config.get_num_block_offset_bits();
  uint32_t tag = cache_config.get_num_tag_bits();

  if (tag > 31) {
    return 0;
  }
  return ((address << tag) >> (tag + offset));
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t index = cache_config.get_num_index_bits();
  uint32_t tag = cache_config.get_num_tag_bits();

  if (tag > 31) {
    return 0;
  }
  uint32_t tag_ind = tag + index;
  return ((address << tag_ind) >> tag_ind);
}
