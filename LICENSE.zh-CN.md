许可证（中文翻译版）

[ENGLISH](LICENSE.md) | 简体中文

翻译声明 | TRANSLATION NOTICE
===

本文档为英文 LICENSE 文件的中文翻译版本，仅供参考和理解使用。

重要提示：
- 本翻译为非官方翻译，不具备法律效力
- 如中英文版本之间存在任何差异或冲突，以英文版本为准
- 所有法律解释和争议应以英文原版为依据
- 本翻译不构成法律建议

This is an unofficial Chinese translation of the LICENSE file for reference 
and understanding purposes only.

IMPORTANT:
- This translation has no legal effect
- In case of any discrepancy between English and Chinese versions, the 
  English version shall prevail
- All legal interpretations and disputes shall be based on the English version
- This translation does not constitute legal advice

English LICENSE file: LICENSE

MARIONET 项目许可证
===

最后更新：2025-10-19
文档版本：1.0

注意：本许可证文档可能会更新。请查看代码仓库以获取最新版本。
本文件的版本控制历史可在项目的 Git 仓库中找到。

重要声明
===

本项目由多个具有不同许可证的软件组件组成。
用户在构建、使用或分发本软件时，必须遵守所有适用的许可证。

关键依赖声明：
---
本项目的渲染组件设计为与 GDCubism 插件配合工作，该插件会链接到 Live2D 
Cubism SDK for Native。如果没有 GDCubism 插件，渲染功能将无法使用。

重要提示：
---
**框架的其他组件（核心逻辑、服务层、功能模块）不依赖于 Live2D SDK，
可以独立运行。无论是否使用 Live2D 组件，Marionet 框架本身都保持其 
Apache 2.0 许可证。**

代码仓库内容：

本仓库包含：
- 完整的 Godot 项目文件
- 核心框架的 C# 源代码
- GDCubism 插件集成代码
- Live2D 官方发布的免费开源模型文件（如有）

本仓库不包含：
- 已编译的 GDCubism 插件二进制文件（.dll、.so、.dylib）
- Live2D Cubism SDK 二进制文件或源代码

**注意：如果本仓库包含 Live2D 模型文件，这些模型均为 Live2D Inc. 官方
发布的免费开源模型，受其各自的开源许可证约束。用户自定义的 Live2D 
模型文件不包含在仓库中，需要用户自行准备。**


**用户必须自行编译 GDCubism 插件，或单独获取预编译的二进制文件。**

组件许可证摘要
===

|             组件             |    许可证     |   适用范围   |
| ---------------------------- | ------------ | ----------- |
| Marionet 核心框架            | Apache 2.0   | 所有原创代码 |
| GDCubism 插件（源代码）       | MIT          | 插件源代码   |
| GDCubism 插件（编译后二进制） | MIT + Live2D | 编译后       |
| Live2D Cubism SDK            | Live2D 专有   | 分发时       |
| Godot 引擎                   | MIT          | 运行时环境   |

重要说明：
---

Marionet 框架（核心、服务、功能）采用 Apache 2.0 许可证，无论是否使用 
Live2D 组件，该许可证都保持不变。只有在分发包含与 Live2D SDK 链接的 
GDCubism 二进制文件的已编译应用程序时，才会受到 Live2D 许可证的影响。

用户可以选择：
1. 使用包含 Live2D 的完整系统（分发时需遵守 Live2D 许可证）
2. 不使用 Live2D 组件使用框架（仅 Apache 2.0）
3. 用替代方案替换渲染组件（仅 Apache 2.0）

---

1.MARIONET 核心框架
===

许可证：Apache License 2.0
版权所有：2024 TLSLime (https://github.com/TLSLime)
          2024 Forwindz (https://github.com/Forwindz)

注意：无论是否与 Live2D 组件集成，Marionet 框架都保持其 Apache 2.0 许可证
的独立性。用户可以自由地在 Apache 2.0 条款下使用、修改和分发框架，无论
是否使用 Live2D。

适用于：
- /src/Core/              核心框架（感知、决策、调度）
- /src/Services/          服务层（LLM、TTS、内存、缓存）
- /src/Features/          功能模块（仪式、好感度等）
- /src/Utils/             工具类
- /scenes/                Godot 场景文件
- /resources/data/        配置和数据文件
- /tests/                 单元测试
- /docs/                  文档

**重要提示：渲染组件（/src/Renderer/ 或等效目录）与 GDCubism 集成，编译后
将受到额外许可条款的约束。**

                            Apache 许可证
                        版本 2.0，2004 年 1 月
                    http://www.apache.org/licenses/

使用、复制和分发的条款和条件

   1. 定义。

      "许可证"是指本文档第 1 至 9 节定义的使用、复制和分发的条款和条件。

      "许可方"是指授予许可证的版权所有者或由版权所有者授权的实体。

      "法律实体"是指行为实体与控制该实体、受该实体控制或与该实体共同
      受控的所有其他实体的联合体。就本定义而言，"控制"是指 (i) 直接或
      间接地导致该实体的指导或管理的权力，无论是通过合同还是其他方式，
      或 (ii) 拥有百分之五十 (50%) 或更多的已发行股份的所有权，或 
      (iii) 该实体的受益所有权。

      "您"（或"您的"）是指行使本许可证授予的权限的个人或法律实体。

      "源代码"形式是指进行修改的首选形式，包括但不限于软件源代码、
      文档源代码和配置文件。

      "目标代码"形式是指源代码形式经机械转换或翻译而产生的任何形式，
      包括但不限于已编译的目标代码、生成的文档以及转换为其他媒体类型。

      "作品"是指根据许可证提供的著作作品，无论是源代码形式还是目标代码
      形式，如作品中包含或附加的版权声明所示（附录中提供了示例）。

      "衍生作品"是指基于作品（或源于作品）的任何作品，无论是源代码形式
      还是目标代码形式，其中编辑修订、注释、详细说明或其他修改作为整体
      代表原创著作作品。就本许可证而言，衍生作品不包括与作品及其衍生作品
      的接口保持可分离或仅链接（或按名称绑定）的作品。

      "贡献"是指任何著作作品，包括作品的原始版本以及对该作品或其衍生作品
      的任何修改或添加，由版权所有者或由版权所有者授权代表提交的个人或
      法律实体有意提交给许可方以包含在作品中。就本定义而言，"提交"是指
      发送给许可方或其代表的任何形式的电子、口头或书面通信，包括但不限于
      在电子邮件列表、源代码控制系统以及由许可方或代表许可方管理的用于
      讨论和改进作品的问题跟踪系统上的通信，但不包括版权所有者明确标记
      或以书面形式指定为"非贡献"的通信。

      "贡献者"是指许可方以及许可方已收到贡献并随后纳入作品的任何个人或
      法律实体。

   2. 版权许可的授予。根据本许可证的条款和条件，每个贡献者在此授予您
      永久的、全球性的、非排他性的、免费的、免版税的、不可撤销的版权
      许可证，以源代码或目标代码形式复制、准备衍生作品、公开展示、
      公开表演、再许可和分发作品及此类衍生作品。

   3. 专利许可的授予。根据本许可证的条款和条件，每个贡献者在此授予您
      永久的、全球性的、非排他性的、免费的、免版税的、不可撤销的（除非
      本节另有说明）专利许可证，以制造、委托制造、使用、要约出售、销售、
      进口和以其他方式转让作品，该许可证仅适用于该贡献者可许可的专利
      权利要求，这些权利要求必然会因其单独的贡献或其贡献与提交该贡献的
      作品的组合而受到侵犯。如果您对任何实体提起专利诉讼（包括诉讼中的
      交叉请求或反诉），声称作品或作品中包含的贡献构成直接或间接的专利
      侵权，则根据本许可证授予您的该作品的任何专利许可证应自提起该诉讼
      之日起终止。

   4. 再分发。您可以在任何媒介中复制和分发作品或其衍生作品的副本，
      无论是否修改，也无论是源代码形式还是目标代码形式，前提是您满足
      以下条件：

      (a) 您必须向作品或衍生作品的任何其他接收者提供本许可证的副本；

      (b) 您必须使任何修改的文件带有显著的声明，说明您更改了文件；

      (c) 您必须在您分发的任何衍生作品的源代码形式中保留作品源代码形式
          中的所有版权、专利、商标和归属声明，但不包括与衍生作品的任何
          部分无关的声明；

      (d) 如果作品在其分发中包含"NOTICE"文本文件，则您分发的任何衍生
          作品必须在以下至少一个位置包含该 NOTICE 文件中包含的归属声明
          的可读副本，但不包括与衍生作品的任何部分无关的声明：在作为
          衍生作品一部分分发的 NOTICE 文本文件中；在源代码形式或文档中
          （如果与衍生作品一起提供）；或在衍生作品生成的显示中（如果
          此类第三方声明通常出现的话）。NOTICE 文件的内容仅供参考，不
          修改许可证。您可以在您分发的衍生作品中添加您自己的归属声明，
          作为作品中 NOTICE 文本的附录或补充，前提是此类额外的归属声明
          不能被解释为修改许可证。

      您可以为您的修改添加您自己的版权声明，并可以为您的修改的使用、
      复制或分发或任何此类衍生作品整体提供额外或不同的许可条款和条件，
      前提是您对作品的使用、复制和分发符合本许可证中规定的条件。

   5. 贡献的提交。除非您明确声明，否则您有意提交给许可方以包含在作品
      中的任何贡献均应遵守本许可证的条款和条件，不附加任何额外条款或
      条件。尽管有上述规定，本协议的任何内容均不得取代或修改您可能与
      许可方就此类贡献签订的任何单独许可协议的条款。

   6. 商标。本许可证不授予使用许可方的商号、商标、服务标记或产品名称
      的许可，除非在描述作品来源和复制 NOTICE 文件内容时合理和习惯
      使用所需。

   7. 免责声明。除非适用法律要求或书面同意，否则许可方按"原样"提供
      作品（每个贡献者提供其贡献），不提供任何明示或暗示的保证或条件，
      包括但不限于对所有权、非侵权、适销性或特定用途适用性的任何保证
      或条件。您全权负责确定使用或再分发作品的适当性，并承担因您行使
      本许可证下的权限而产生的任何风险。

   8. 责任限制。在任何情况下，根据任何法律理论，无论是侵权（包括过失）、
      合同还是其他方面，除非适用法律要求（例如故意和重大过失行为）或
      书面同意，否则任何贡献者均不对您承担损害赔偿责任，包括因本许可证
      或使用或无法使用作品而产生的任何直接、间接、特殊、偶然或后果性
      损害（包括但不限于商誉损失、停工、计算机故障或故障，或任何和所有
      其他商业损害或损失），即使该贡献者已被告知此类损害的可能性。

   9. 接受保证或额外责任。在再分发作品或其衍生作品时，您可以选择提供
      并收取费用，以接受与本许可证一致的支持、保证、赔偿或其他责任义务
      和/或权利。但是，在接受此类义务时，您只能代表自己并承担全部责任，
      而不能代表任何其他贡献者，并且仅当您同意赔偿、辩护和使每个贡献者
      免受因您接受任何此类保证或额外责任而产生的或对该贡献者提出的任何
      责任或索赔时，才能这样做。

   条款和条件结束

---

2.GDCUBISM 插件
===

许可证：MIT License
版权所有：(c) 2023 MizunagiKB
代码仓库：https://github.com/MizunagiKB/gd_cubism

关键信息：

GDCubism 是一个连接 Godot 引擎与 Live2D Cubism SDK 的 Godot 插件。

插件源代码本身采用 MIT 许可证。但是，当插件被编译时，它会与 Live2D 
Cubism SDK for Native 链接，从而创建一个受 Live2D 专有许可条款约束的
二进制文件。

依赖范围：

- Marionet 的渲染组件设计为与 GDCubism 插件配合工作
- 如果没有 GDCubism 插件二进制文件，Live2D 渲染将无法运行
- 其他框架组件（服务、功能、核心逻辑）可以独立运行，无需 GDCubism 
  或 Live2D SDK
- 框架的 Apache 2.0 许可证不受可选使用 Live2D 组件的影响

MIT 许可证文本：

特此免费授予任何获得本软件及相关文档文件（"软件"）副本的人不受限制地
处理软件的权利，包括但不限于使用、复制、修改、合并、发布、分发、再许可
和/或出售软件副本的权利，以及允许获得软件的人这样做的权利，但须符合
以下条件：

上述版权声明和本许可声明应包含在软件的所有副本或主要部分中。

软件按"原样"提供，不提供任何明示或暗示的保证，包括但不限于对适销性、
特定用途适用性和非侵权的保证。在任何情况下，作者或版权持有人均不对
任何索赔、损害或其他责任负责，无论是在合同诉讼、侵权行为还是其他方面，
由软件或软件的使用或其他交易引起、产生或与之相关。

---

3.LIVE2D CUBISM SDK FOR NATIVE
===

许可证：Live2D 专有软件许可证
版权所有：Live2D Inc.
网站：https://www.live2d.com/

关于 LIVE2D 许可证的解释说明：

当 GDCubism 与 Live2D SDK 一起编译时，Live2D 许可证适用于组合作品。
即使在使用启用 Live2D 的二进制文件时，Marionet 框架本身仍保持 
Apache 2.0 许可证。

这意味着：
- Marionet 核心源代码（Apache 2.0）可以独立自由使用、修改和分发
- 当将 GDCubism 插件二进制文件（使用 Live2D SDK 编译）集成到项目中时，分发完整应用程序需要遵守 Live2D 的许可条款
- 用户可以选择在不使用 Live2D 组件的情况下使用 Marionet 框架，仅受 Apache 2.0 条款约束

适用性：

本许可证仅在以下情况适用：
1. 您使用 Live2D Cubism SDK 编译 GDCubism 插件
2. 您分发生成的已编译二进制文件
3. 您使用依赖于 Live2D 的渲染功能

不适用于：
- 不使用 Live2D 的核心框架组件
- 使用 Live2D SDK 进行开发和测试
- 不包含已编译二进制文件的源代码分发

许可证类型：

A. 开发许可证（免费）
   协议：Live2D Open Software License
   链接：https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html
   
   允许的用途：
   - 学习和研究
   - 内部开发和测试
   - 分发给有限群体进行测试
   
   限制：
   - 未经额外许可不得公开分发
   - 未经付费不得用于商业产品

B. 商业分发许可证（付费）
   协议：Live2D Proprietary Software License
   链接：https://www.live2d.com/eula/live2d-proprietary-software-license-agreement_en.html
   
   需要获得许可的情况：
   - 公开分发已编译的二进制文件
   - 商业应用程序
   - 通过应用商店分发的产品
   
   选项：
   1. 免费层级：年收入 < 100 万美元
      注册地址：https://www.live2d.com/en/download/cubism-sdk/
   
   2. 付费许可证：用于更大的项目
      联系：license@live2d.com
   
   3. 收入分成：固定费用的替代方案
      详情：联系 Live2D Inc.

关键限制：

当您使用 Live2D Cubism SDK 编译此项目时，生成的二进制文件将成为与 
Live2D 专有库链接的衍生作品。

分发此类二进制文件需要：
- 遵守 Live2D 专有软件许可证
- 根据使用规模获得适当的许可
- 提供适当的归属和许可声明

重要提示：本仓库不包含 Live2D SDK。用户必须从 Live2D Inc. 单独下载并接受其许可协议。

关于本仓库中的 LIVE2D 模型文件：

本仓库可能包含用于演示目的的 Live2D 模型文件。如果包含，这些模型：
- 为 Live2D Inc. 官方发布的免费开源模型
- 来自 Live2D 官方示例模型仓库
- 受其各自的开源许可证约束（通常允许免费使用）
- 不是 Marionet 项目创建的自定义模型

希望使用自定义 Live2D 模型的用户必须：
- 创建或获取自己的模型
- 确保遵守 Live2D 的模型许可条款
- 将模型文件放置在 resources/models/ 目录中

官方资源：
- SDK 下载：https://www.live2d.com/en/download/cubism-sdk/download-native/
- 许可证信息：https://www.live2d.com/en/download/cubism-sdk/#license
- 联系方式：license@live2d.com

---

4.GODOT 引擎
===

许可证：MIT License
版权所有：Godot Engine 贡献者
网站：https://godotengine.org/

Godot Engine 用作运行时环境，不包含在本仓库中。用户必须单独安装 Godot。

许可证详情：https://godotengine.org/license

---

分发指南
===

分发源代码：

您可以在以下条件下分发 Marionet 源代码：

允许：
- 分叉和修改仓库
- 在 Apache 2.0 下共享修改
- 包含在商业项目中（仅限 Marionet 代码）
- 不包含 Live2D SDK 或 GDCubism 二进制文件的分发

要求：
- 包含此 LICENSE 文件
- 包含 NOTICE 文件（如果提供）
- 声明对代码所做的更改
- 为原作者提供归属
- 不得包含 Live2D SDK 或已编译的 GDCubism 二进制文件
- 指导用户单独获取这些组件

分发已编译的二进制文件：

警告：包含与 Live2D SDK 链接的 GDCubism 插件的已编译二进制文件受 Live2D 专有许可证的约束。

在分发已编译的二进制文件之前，您必须：

1. 获得适当的 Live2D Cubism SDK 许可证
   - 如果年收入 < 100 万美元，可使用免费层级
   - 更大的项目需要付费许可证
   
2. 遵守 Live2D 许可条款
   - 包含所需的许可声明
   - 提供适当的归属
   - 遵守分发限制
   
3. 包含所有必需的许可文件
   - 此 LICENSE 文件
   - Live2D 许可协议
   - GDCubism MIT 许可声明
   
4. 向最终用户清楚地说明许可状态

重要提示：如果您在未获得适当的 Live2D 许可的情况下分发二进制文件，您可能违反 Live2D 的专有软件许可证。

替代方案：不使用 LIVE2D 的分发：

如果您希望在不获得 Live2D 许可的情况下分发：
- 移除或替换使用 GDCubism 的渲染组件
- 使用替代渲染解决方案
- 核心框架功能仍在 Apache 2.0 下可用
- 框架的 Apache 2.0 许可证不受此选择的影响

开发与构建
===

面向开发者：

为个人使用或测试构建此项目时：

无需 Live2D 许可证即可：
- 克隆此仓库
- 使用 Live2D SDK 编译用于开发
- 本地测试和调试
- 为个人使用修改代码
- 以源代码形式共享修改

未获得 Live2D 许可证不可：
- 公开分发已编译的二进制文件
- 在应用商店发布
- 包含在商业产品中
- 部署到公共服务器

编译要求：

要构建具有渲染功能的完整项目：

1. 获取 Live2D Cubism SDK for Native
   - 下载地址：https://www.live2d.com/en/download/cubism-sdk/download-native/
   - 接受 Live2D Open Software License 用于开发
   
2. 编译 GDCubism 插件
   - 按照说明操作：https://github.com/MizunagiKB/gd_cubism
   - 与 Live2D SDK 链接
   - 输出：已编译的插件二进制文件（.dll、.so、.dylib）
   
3. 将插件集成到 Godot 项目中
   - 将已编译的二进制文件放置在 addons/gd_cubism/bin/ 中
   - 在 Godot 项目设置中启用插件

重要提示：本仓库不包含已编译的 GDCubism 插件二进制文件。
用户必须自行编译或从授权来源获取。

第三方依赖
===

此项目可能使用其他第三方库和工具。每个都有自己的许可条款：

- .NET SDK 和运行时：MIT License
- C# 语言库：多种（主要是 MIT）
- 其他 NuGet 包：请参阅各个包的许可证

请参阅项目依赖文件以获取完整列表。

免责声明
===

本许可证文档仅供参考。它不构成法律建议。

对于权威的许可证信息，请始终参考：
- 原始 Apache 2.0 许可证：https://www.apache.org/licenses/LICENSE-2.0
- 原始 MIT 许可证：https://opensource.org/licenses/MIT  
- 官方 Live2D 许可证：https://www.live2d.com/eula/

本项目的维护者不负责确保遵守第三方许可证。用户自行负责：
- 理解所有适用的许可条款
- 在分发前获得必要的许可证
- 确保遵守所有法律要求

如有疑问，请咨询合格的法律专业人士。

联系信息
===

Marionet 项目：
- 代码仓库：https://github.com/TLSLime/Marionet
- 问题反馈：https://github.com/TLSLime/Marionet/issues
- 维护者：
  * TLSLime: https://github.com/TLSLime
  * Forwindz: https://github.com/Forwindz

GDCubism 插件：
- 代码仓库：https://github.com/MizunagiKB/gd_cubism
- 作者：MizunagiKB

Live2D Inc.：
- 网站：https://www.live2d.com/
- 许可证咨询：license@live2d.com
- 技术支持：https://www.live2d.com/en/support/

致谢
===

本项目由以下人员开发和维护：
- Forwindz (https://github.com/Forwindz)
- TLSLime (https://github.com/TLSLime)

本项目使用了以下内容：
- Live2D Inc. 的 Live2D Cubism SDK
- MizunagiKB 的 GDCubism 插件
- Godot Engine 贡献者的 Godot Engine
- 各种开源库和工具

我们感谢所有这些项目的贡献者和维护者。

许可证文档结束
===

注意：本文档为非官方中文翻译，仅供参考。
如有任何法律问题，请以英文版 LICENSE 文件为准。

NOTE: This is an unofficial Chinese translation for reference only.
For any legal matters, please refer to the English LICENSE file.