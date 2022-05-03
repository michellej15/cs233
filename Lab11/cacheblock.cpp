#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  uint32_t offset = _cache_config.get_num_block_offset_bits();
  uint32_t index = _cache_config.get_num_index_bits();
  uint32_t rtag = get_tag();

  rtag = ((rtag << index) + _index);
  return (rtag << offset);
}
