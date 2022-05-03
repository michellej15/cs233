#include "simplecache.h"

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details
  auto find = _cache.find(index);
  for (int i = 0; i < _associativity; i++) {
    auto look = find->second[i];
    if (look.valid() && (look.tag() == tag)) {
      return look.get_byte(block_offset);
    }
  }
  return 0xdeadbeef;
}

void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign (see "C++ Rule of Three")
  auto find = _cache.find(index);
  for (int i = 0; i < _associativity; i++) {
    auto &look = find->second[i];
    if (!look.valid()) {
      look.replace(tag, data);
      return;
    }
  }
  auto &look2 = find->second[0];
  look2.replace(tag, data);
}
