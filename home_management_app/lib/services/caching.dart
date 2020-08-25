import 'package:flutter/material.dart';

class Caching{

  List<Cache> store = List<Cache>();

  add(String key, Object value){
    this.remove(key);
    this.store.add(Cache(key: key, value: value));
  }

  remove(String key){
    if(this.store.any((element) => element.key == key)){
      this.store.removeWhere((element) => element.key == key);
    }
  }

  exists(String key) => this.store.any((element) => element.key == key);

  fetch(String key){
    if(this.store.any((element) => element.key == key)){
      var first = this.store.firstWhere((element) => element.key == key);
      return first.value;
    }else{
      return null;
    }
  }
}

class Cache{

  Cache({@required this.key, @required this.value});

  String key;
  Object value;
}