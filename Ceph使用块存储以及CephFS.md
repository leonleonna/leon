## Ceph使用块存储以及CephFS

---

> Date：2020-05-26
>
> Author：Leon

### 一、前言

1. ceph使用ceph-deploy快速部署，不在叙述安装过程
2. 此文档建立在ceph15.2.2之上
3. 此次操作均在node1(mon),同时担当client作测试

### 二、使用块儿存储

```shell
# 确认实验环境正常
  ceph health

# 创建Pool pg pgp 保持一致为64 crush使用默认复制
# 需要更改的话使用 ceph osd pool set pg_num 128
# 同时可以在集群扩容的时候设置标志位 
  ceph osd pool create block-demo 64 64
  rbd pool init block-demo
  ceph osd pool ls
  
# 创建块儿设备
  rbd create -p block-demo --image=block.img -s 2G
  ## 或者这样创建
  rbd create block-demo/block2.img -s 2G
  
# 查看创建的块儿设别
  rbd -p block-demo ls
  ## 或者这样查看
  rbd ls block-demo
  ## 或者这样查看信息
  rbd info block-demo/block2.img
  
# 删除块儿设备
  rbd -p block-demo rm block2.img
  ## 或者这样删
  rbd  rm block-demo/block2.img
  
# 恢复已删除的块儿文件
  ## 这里删除指 延迟删除 加参数  --expires-at 
  rbd trash rm block-demo/block.img
  ## 直接rm 是恢复不了的
  rbd info block-demo/block2.img | grep id
  rbd trash mv block-demo/block2.img --expires-at 10m
  ## 恢复
  rbd trash restore block-demo/1513af635e39
  
  
# 块儿设备扩容
  rbd resize -s 3G block-demo/block.img
  ## 或者这样写
  rbd -p block-demo resize block.img -s 3G
  
# 块儿设备缩容(生产环境尽量就不要用了)
  rbd resize -s 3G block-demo/block.img --allow-shrink
  ## 或者这样写
  rbd -p block-demo resize block.img -s 3G  --allow-shrink
   
# 内核级别挂载块设备 
  ## 挂载之前需要关闭内核不支持的feature
  rbd feature disable block-demo/block.img object-map fast-diff deep-flatten
  rbd map block-demo/block.img
  rbd device list
  mkfs.xfs /dev/rbd0
  mkdir rbdtest; mount /dev/rbd0 rbdtest
  echo 'test rbd' > rbdtest/rbd.txt
  
# 
  
  
```

