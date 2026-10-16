-- ============================================================================
--  尚舆分析平台 — 私域舆情库初始化脚本（本地跑通演示用）
--
--  用途：创建 Insight Agent 私域检索所需的 MySQL 库表，并灌入一批中文演示数据。
--  表结构与字段名严格对齐代码中的映射配置：
--      engines/insight_agent/tools/platform_mappings.py
--  字段语义：
--      create_time 为 Unix 秒级时间戳（代码按 int(timestamp) 做时间窗过滤，
--      热度召回默认取最近 365 天，故这里统一用「当前时间往前推」保证数据新鲜）。
--      source_keyword 为采集该内容时使用的检索词，同时参与私域五维聚类规则命中。
--
--  执行方式：
--      mysql -uroot -p --default-character-set=utf8mb4 < scripts/init_demo_db.sql
--  注意：脚本会 DROP 掉这四张表，只对本库生效，不会动其他库。
-- ============================================================================

CREATE DATABASE IF NOT EXISTS media_crawler_v1
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE media_crawler_v1;

-- ---------------------------------------------------------------------------
-- 抖音作品表
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS douyin_aweme;
CREATE TABLE douyin_aweme
(
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title           TEXT            DEFAULT NULL COMMENT '作品文案/标题',
    create_time     BIGINT          DEFAULT NULL COMMENT 'Unix 秒级时间戳',
    source_keyword  VARCHAR(255)    DEFAULT NULL COMMENT '采集检索词',
    liked_count     INT             DEFAULT 0 COMMENT '点赞数',
    comment_count   INT             DEFAULT 0 COMMENT '评论数',
    share_count     INT             DEFAULT 0 COMMENT '分享数',
    collected_count INT             DEFAULT 0 COMMENT '收藏数',
    PRIMARY KEY (id),
    KEY idx_source_keyword (source_keyword),
    KEY idx_create_time (create_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------------------
-- 抖音评论表
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS douyin_aweme_comment;
CREATE TABLE douyin_aweme_comment
(
    id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    content           TEXT            DEFAULT NULL COMMENT '评论内容',
    create_time       BIGINT          DEFAULT NULL COMMENT 'Unix 秒级时间戳',
    like_count        INT             DEFAULT 0 COMMENT '评论点赞数',
    sub_comment_count INT             DEFAULT 0 COMMENT '子评论数',
    PRIMARY KEY (id),
    KEY idx_create_time (create_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------------------
-- 微博帖子表
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS weibo_note;
CREATE TABLE weibo_note
(
    id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    content        TEXT            DEFAULT NULL COMMENT '微博正文',
    create_time    BIGINT          DEFAULT NULL COMMENT 'Unix 秒级时间戳',
    source_keyword VARCHAR(255)    DEFAULT NULL COMMENT '采集检索词',
    liked_count    INT             DEFAULT 0 COMMENT '点赞数',
    comments_count INT             DEFAULT 0 COMMENT '评论数',
    shared_count   INT             DEFAULT 0 COMMENT '转发数',
    PRIMARY KEY (id),
    KEY idx_source_keyword (source_keyword),
    KEY idx_create_time (create_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------------------
-- 微博评论表
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS weibo_note_comment;
CREATE TABLE weibo_note_comment
(
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    content             TEXT            DEFAULT NULL COMMENT '评论内容',
    create_time         BIGINT          DEFAULT NULL COMMENT 'Unix 秒级时间戳',
    comment_like_count  INT             DEFAULT 0 COMMENT '评论点赞数',
    sub_comment_count   INT             DEFAULT 0 COMMENT '子评论数',
    PRIMARY KEY (id),
    KEY idx_create_time (create_time)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

-- ============================================================================
--  演示数据：虚构舆情事件「AI 换脸诈骗案」
--  用当前时间往前推生成时间戳，保证落在热度召回的时间窗内。
-- ============================================================================

INSERT INTO douyin_aweme (title, create_time, source_keyword, liked_count, comment_count, share_count, collected_count)
VALUES ('警方通报AI换脸诈骗案：受害人在视频通话中被人脸替换的“亲友”骗走86万元，案件正在进一步侦办中',
        UNIX_TIMESTAMP(NOW() - INTERVAL 9 DAY), 'AI换脸', 128000, 4300, 9200, 3100),
       ('官方发布反诈预警：近期AI换脸冒充熟人视频通话的作案手法明显增多，请务必电话二次核实',
        UNIX_TIMESTAMP(NOW() - INTERVAL 8 DAY), 'AI换脸', 96000, 2800, 15000, 2600),
       ('现场视频曝光：嫌疑人落网画面，案件起因系该团伙从社交平台批量购买人脸素材后训练模型',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 'AI换脸', 210000, 6100, 24000, 5400),
       ('AI换脸诈骗冲上热搜第一，相关话题阅读量一夜之间破十亿，多个账号跟进科普如何识别换脸视频',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 'AI换脸诈骗', 340000, 8800, 41000, 12000),
       ('这条视频三天转发过万，评论区的担心几乎一边倒：以后连视频都不能信了吗',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 'AI换脸', 175000, 12000, 52000, 7300),
       ('点赞最高的评论：不是技术太强，是个人隐私泄露得太容易，人脸数据早就在网上裸奔了',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 'AI换脸', 62000, 3400, 4100, 1900),
       ('支持严管的声音占多数，也有人担心技术被误伤：正常的内容创作会不会一起被限流',
        UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY), 'AI换脸诈骗', 88000, 5200, 3600, 2400),
       ('态度两极分化明显，网友看法分成两派：一派要求平台先行赔付，一派认为用户自己也要提高警惕',
        UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY), 'AI换脸', 54000, 4700, 2200, 1300),
       ('微博与抖音的讨论重点完全不同：微博在讨论立法与平台责任，抖音在教普通人怎么自证没被骗',
        UNIX_TIMESTAMP(NOW() - INTERVAL 4 DAY), 'AI换脸', 47000, 2600, 3100, 900),
       ('自媒体大V集体发声，粉丝反应两极：有人整理出防骗清单，也有人质疑这是在制造恐慌',
        UNIX_TIMESTAMP(NOW() - INTERVAL 4 DAY), 'AI换脸诈骗', 73000, 3900, 5800, 2100),
       ('深层原因：人脸数据买卖已经形成完整的灰色产业链，背后是采集环节的长期失守',
        UNIX_TIMESTAMP(NOW() - INTERVAL 3 DAY), 'AI换脸', 91000, 4100, 8700, 3300),
       ('后续影响开始显现：多地开展反诈宣传进社区，有学者提醒社会信任成本被显著抬高，监管面临新挑战',
        UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY), 'AI换脸诈骗', 66000, 3000, 6200, 2000),
       ('专家解读风险外溢：这类案件的技术门槛还在快速下降，普通人遭遇的概率在上升',
        UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY), 'AI换脸', 39000, 1800, 2700, 1100),
       ('平台回应质疑：已下架违规视频327条，封禁相关账号46个，并将上线换脸标识功能',
        UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY), 'AI换脸诈骗', 82000, 5600, 4900, 1800);

INSERT INTO douyin_aweme_comment (content, create_time, like_count, sub_comment_count)
VALUES ('我上周就接到过这种视频通话，还好当时多问了一句只有家人才知道的细节，现在想想后背发凉',
        UNIX_TIMESTAMP(NOW() - INTERVAL 8 DAY), 24000, 610),
       ('关键是取证太难了，等发现被骗的时候钱早就被层层转走了，普通家庭根本扛不住这种损失',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 18000, 420),
       ('吐槽一下某些平台，人脸素材都能随便爬，出了事才想起来整改，早干嘛去了',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 15000, 380),
       ('说实话我更担心的是家里老人，他们根本分辨不出换脸的痕迹，跟他们讲了也记不住',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 31000, 900),
       ('不能一禁了之吧，AI换脸在影视修复正片里是有用的，一刀切最后受伤的是正常创作者',
        UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY), 12000, 750),
       ('强烈支持严管，但更希望看到的是采集端处罚，光管生成端等于堵住下水道上游照样倒水',
        UNIX_TIMESTAMP(NOW() - INTERVAL 4 DAY), 21000, 530),
       ('理解大家的愤怒，不过也提醒一句，最好的防线还是那句老话：涉及转账一律挂断后回拨核实',
        UNIX_TIMESTAMP(NOW() - INTERVAL 3 DAY), 27000, 340),
       ('看过一个博主的实测，用开源模型几分钟就能合成一段以假乱真的视频，这才是最让人担心的',
        UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY), 9500, 280);

INSERT INTO weibo_note (content, create_time, source_keyword, liked_count, comments_count, shared_count)
VALUES ('【警方通报】AI换脸冒充亲友实施诈骗案告破，三名嫌疑人已被刑事拘留，涉案金额超200万元。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 9 DAY), 'AI换脸', 56000, 3200, 12000),
       ('官方声明来了：针对近期高发的AI换脸诈骗，相关部门将开展为期三个月的专项整治。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 8 DAY), 'AI换脸诈骗', 43000, 2100, 9800),
       ('这条热搜挂了一整天：AI换脸诈骗为什么突然爆发？舆论场上的追问主要集中在数据来源和平台责任两点。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 'AI换脸', 78000, 5600, 21000),
       ('不少网友在评论区表达愤怒，也有人提出质疑：既然人脸识别被广泛用于开户和支付，谁来保证这些数据不被滥用？',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 'AI换脸诈骗', 35000, 4100, 7600),
       ('值得关注的是平台间差异：微博上讨论集中在监管与立法，短视频平台的讨论则更偏向实用防骗技巧。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY), 'AI换脸', 27000, 1400, 4300),
       ('媒体和社会学者共同发声：技术滥用的背后是长期缺位的数据治理，信任一旦被透支，修复成本极高。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 4 DAY), 'AI换脸诈骗', 31000, 1200, 5200),
       ('后续进展：首批受害者的资金追回程序已经启动，多地法院表示将从严从快审理此类案件。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 3 DAY), 'AI换脸', 22000, 980, 3600),
       ('一个值得警惕的趋势：这类案件的风险正在从名人向普通人扩散，社会整体防范成本明显上升。',
        UNIX_TIMESTAMP(NOW() - INTERVAL 2 DAY), 'AI换脸诈骗', 19000, 760, 2900);

INSERT INTO weibo_note_comment (content, create_time, comment_like_count, sub_comment_count)
VALUES ('通报发得很及时，但更想知道的是这些训练素材到底从哪来的，源头不堵住问题还会再来一轮',
        UNIX_TIMESTAMP(NOW() - INTERVAL 8 DAY), 8600, 320),
       ('支持专项整治，反对只处罚末端账号，真正该问责的是把数据卖出去的那一环',
        UNIX_TIMESTAMP(NOW() - INTERVAL 7 DAY), 7200, 260),
       ('有个担心一直没人正面回答：如果人脸已经泄露了，普通人还能做什么来保护自己',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 11000, 480),
       ('争议焦点其实不是要不要管技术，而是怎么管才不至于让正常的技术应用一起被卡死',
        UNIX_TIMESTAMP(NOW() - INTERVAL 6 DAY), 6400, 390),
       ('微博这边的氛围比短视频平台理性不少，至少大家在讨论法条而不是互相指责',
        UNIX_TIMESTAMP(NOW() - INTERVAL 5 DAY), 5200, 180),
       ('看过几篇深度报道，感觉平台在事前审核上确实有责任，事后下架往往已经晚了',
        UNIX_TIMESTAMP(NOW() - INTERVAL 4 DAY), 9100, 240),
       ('后续希望能有明确的赔付机制，不然受害者只能自己认栽，舆论反弹只会更大',
        UNIX_TIMESTAMP(NOW() - INTERVAL 3 DAY), 4700, 150),
       ('说实话这次舆论的走向还算正面，至少把反诈这件事重新推到了公众视野里',
        UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY), 3800, 110);

SELECT 'douyin_aweme' AS 表名, COUNT(*) AS 行数 FROM douyin_aweme
UNION ALL SELECT 'douyin_aweme_comment', COUNT(*) FROM douyin_aweme_comment
UNION ALL SELECT 'weibo_note', COUNT(*) FROM weibo_note
UNION ALL SELECT 'weibo_note_comment', COUNT(*) FROM weibo_note_comment;
