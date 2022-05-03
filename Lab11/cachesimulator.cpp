#include "cachesimulator.h"

Cache::Block* CacheSimulator::find_block(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    possibly have `address` cached.
   * 2. Loop through all these blocks to see if any one of them actually has
   *    `address` cached (i.e. the block is valid and the tags match).
   * 3. If you find the block, increment `_hits` and return a pointer to the
   *    block. Otherwise, return NULL.
   */
   const CacheConfig &_cache_config = _cache->get_config();
   uint32_t idx = extract_index(address, _cache_config);
   std::vector<Cache::Block*> c_vector = _cache->get_blocks_in_set(idx);
   uint32_t tag = extract_tag(address, _cache_config);
   for (int i = 0; i < c_vector.size(); i++) {
     if (c_vector[i]->get_tag() == tag && c_vector[i]->is_valid()) {
       _hits++;
       return c_vector[i];
     }
   }
  return NULL;
}

Cache::Block* CacheSimulator::bring_block_into_cache(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    cache `address`.
   * 2. Loop through all these blocks to find an invalid `block`. If found,
   *    skip to step 4.
   * 3. Loop through all these blocks to find the least recently used `block`.
   *    If the block is dirty, write it back to memory.
   * 4. Update the `block`'s tag. Read data into it from memory. Mark it as
   *    valid. Mark it as clean. Return a pointer to the `block`.
   */
   const CacheConfig &_cache_config = _cache->get_config();
   uint32_t idx = extract_index(address, _cache_config);
   std::vector<Cache::Block*> c_vector = _cache->get_blocks_in_set(idx);
   uint32_t tag = extract_tag(address, _cache_config);
   uint32_t lru = 1000000;
   Cache::Block *lrub;
   for (int i = 0; i < c_vector.size(); i++) {
     if (!c_vector[i]->is_valid()) {
       c_vector[i]->set_tag(tag);
       c_vector[i]->read_data_from_memory(_memory);
       c_vector[i]->mark_as_valid();
       c_vector[i]->mark_as_clean();
       return c_vector[i];
     }
     if (c_vector[i]->get_last_used_time() < lru) {
       lru = c_vector[i]->get_last_used_time();
       lrub = c_vector[i];
     }
   }
   if (lrub->is_dirty()) {
     lrub->write_data_to_memory(_memory);
   }
   lrub->set_tag(tag);
   lrub->read_data_from_memory(_memory);
   lrub->mark_as_valid();
   lrub->mark_as_clean();
   return lrub;
}

uint32_t CacheSimulator::read_access(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found, use `bring_block_into_cache` cache `address` in `block`.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `read_word_at_offset` to return the data at `address`.
   */
   Cache::Block *caching = find_block(address);
   if (!caching) {
     caching = bring_block_into_cache(address);
   }
   const CacheConfig &_cache_config = _cache->get_config();
   caching->set_last_used_time((++_use_clock).get_count());
   return caching->read_word_at_offset(extract_block_offset(address, _cache_config));
}

void CacheSimulator::write_access(uint32_t address, uint32_t word) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found
   *    a. If the policy is write allocate, use `bring_block_into_cache`.
   *    a. Otherwise, directly write the `word` to `address` in the memory
   *       using `_memory->write_word` and return.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `write_word_at_offset` to to write `word` to `address`.
   * 5. a. If the policy is write back, mark `block` as dirty.
   *    b. Otherwise, write `word` to `address` in memory.
   */
   Cache::Block *caching = find_block(address);
   if (!caching) {
     if (_policy.is_write_allocate()) {
       caching = bring_block_into_cache(address);
     } else {
       _memory->write_word(address, word);
       return;
     }
   }
   caching->set_last_used_time((++_use_clock).get_count());
   const CacheConfig &_cache_config = _cache->get_config();
   caching->write_word_at_offset(word, extract_block_offset(address, _cache_config));
   if (_policy.is_write_back()) {
     caching->mark_as_dirty();
   } else {
     caching->write_data_to_memory(_memory);
   }
}
