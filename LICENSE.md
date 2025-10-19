LICENSE

ENGLISH | [简体中文](LICENSE.zh-CN.md)

MARIONET PROJECT LICENSE
===

Last Updated: 2025-10-19
Document Version: 1.0

NOTE: This license document is subject to updates. Please check the repository 
for the latest version. The version control history of this file can be found 
in the project's Git repository.

LANGUAGE VERSIONS:
- English (Official): LICENSE (this file)
- Chinese (Unofficial translation for reference): LICENSE.zh-CN

In case of any discrepancy between versions, the English version shall prevail.

IMPORTANT NOTICE
===

This project consists of multiple components with different licenses.
Users must comply with all applicable licenses when building, using, or 
distributing this software.

CRITICAL DEPENDENCY NOTICE:
===

The rendering component of this project is designed to work with the GDCubism 
plugin, which in turn links with the Live2D Cubism SDK for Native. Without the 
GDCubism plugin, the rendering functionality cannot be used.

IMPORTANT: Other components of the framework (core logic, services, features) 
do NOT depend on Live2D SDK and can function independently. The Marionet 
framework itself retains its Apache 2.0 license regardless of whether Live2D 
components are used.

REPOSITORY CONTENTS:
---

This repository includes:
- Complete Godot project files
- C# source code for core framework
- GDCubism plugin integration code
- Live2D official free open-source model files (if any)

This repository does NOT include:
- Compiled GDCubism plugin binaries (.dll, .so, .dylib)
- Live2D Cubism SDK binaries or source code

NOTE: If this repository includes Live2D model files, these models are 
official free open-source models released by Live2D Inc., subject to their 
respective open-source licenses. User-created custom Live2D model files are 
not included in the repository and must be prepared by users themselves.

Users must compile the GDCubism plugin themselves or obtain pre-compiled 
binaries separately.

COMPONENT LICENSE SUMMARY
===

| Component                        | License          | Scope of Application |
|---|---|---|
|Marionet Core Framework           | Apache 2.0       | All original code |
|GDCubism Plugin (Source)          | MIT              | Plugin source code |
|GDCubism Plugin (Compiled Binary) | MIT + Live2D     | After compilation |
|Live2D Cubism SDK                 | Live2D Proprietary| When distributed |
|Godot Engine                      | MIT              | Runtime environment |

IMPORTANT CLARIFICATION:
---
The Marionet framework (core, services, features) is licensed under Apache 2.0 
and remains so regardless of whether Live2D components are used. The Live2D 
license only affects distribution when the compiled application includes 
GDCubism binaries linked with Live2D SDK.

Users have the option to:
1. Use the complete system with Live2D (subject to Live2D license for distribution)
2. Use the framework without Live2D components (Apache 2.0 only)
3. Replace the rendering component with alternative solutions (Apache 2.0 only)

---

1.MARIONET CORE FRAMEWORK
===


License: Apache License 2.0
Copyright: 2024 TLSLime (https://github.com/TLSLime)
           2024 Forwindz (https://github.com/Forwindz)

NOTE: The Marionet framework maintains its Apache 2.0 license independent of 
any optional integration with Live2D components. Users are free to use, modify, 
and distribute the framework under Apache 2.0 terms with or without Live2D.

Applies to:
- /src/Core/              Core framework (Perception, Decision, Dispatcher)
- /src/Services/          Service layer (LLM, TTS, Memory, Cache)
- /src/Features/          Feature modules (Rituals, Affection, etc.)
- /src/Utils/             Utility classes
- /scenes/                Godot scene files
- /resources/data/        Configuration and data files
- /tests/                 Unit tests
- /docs/                  Documentation

IMPORTANT: The rendering component (/src/Renderer/ or equivalent) integrates 
with GDCubism and is subject to additional license terms when compiled.

                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

---

2.GDCUBISM PLUGIN
===

License: MIT License
Copyright: (c) 2023 MizunagiKB
Repository: https://github.com/MizunagiKB/gd_cubism

CRITICAL INFORMATION:

GDCubism is a Godot plugin that bridges Godot Engine with Live2D Cubism SDK.

The plugin source code itself is under MIT License. However, when the plugin 
is compiled, it links with the Live2D Cubism SDK for Native, creating a binary 
that is subject to Live2D's proprietary license terms.

DEPENDENCY SCOPE:

- The rendering component of Marionet is designed to work with GDCubism plugin
- Without GDCubism plugin binaries, Live2D rendering will not function
- Other framework components (services, features, core logic) can function 
  independently without GDCubism or Live2D SDK
- The Apache 2.0 license of the framework is not affected by the optional 
  use of Live2D components

MIT License Text:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

3.LIVE2D CUBISM SDK FOR NATIVE
===

License: Live2D Proprietary Software License
Copyright: Live2D Inc.
Website: https://www.live2d.com/

NOTE ON LIVE2D LICENSE INTERPRETATION:

The Live2D license applies to the combined work when GDCubism is compiled 
with Live2D SDK. The Marionet framework itself remains under Apache 2.0 
even when used with Live2D-enabled binaries.

This means:
- The Marionet core source code (Apache 2.0) can be freely used, modified, 
  and distributed independently
- When GDCubism plugin binaries (compiled with Live2D SDK) are integrated 
  into the project, distribution of the complete application requires 
  compliance with Live2D's license terms
- Users can choose to use Marionet framework without Live2D components, 
  remaining solely under Apache 2.0 terms

APPLICABILITY:

This license applies ONLY when:
1. You compile GDCubism plugin with Live2D Cubism SDK
2. You distribute the resulting compiled binaries
3. You use the rendering functionality that depends on Live2D

It does NOT apply to:
- Core framework components that do not use Live2D
- Development and testing with Live2D SDK
- Source code distribution without compiled binaries

LICENSE TYPES:

A. Development License (Free)
   Agreement: Live2D Open Software License
   URL: https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html
   
   Permitted uses:
   - Learning and research
   - Internal development and testing
   - Distribution to limited groups for testing purposes
   
   Restrictions:
   - Cannot distribute publicly without additional license
   - Cannot use in commercial products without payment

B. Commercial Distribution License (Paid)
   Agreement: Live2D Proprietary Software License
   URL: https://www.live2d.com/eula/live2d-proprietary-software-license-agreement_en.html
   
   Required for:
   - Public distribution of compiled binaries
   - Commercial applications
   - Products distributed through app stores
   
   Options:
   1. Free tier: Annual revenue < $1,000,000 USD
      Registration required at: https://www.live2d.com/en/download/cubism-sdk/
   
   2. Paid license: For larger projects
      Contact: license@live2d.com
   
   3. Revenue share: Alternative to fixed fee
      Details: Contact Live2D Inc.

KEY RESTRICTIONS:

When you compile this project with Live2D Cubism SDK, the resulting binary 
becomes a derivative work that links with Live2D's proprietary libraries.

Distribution of such binaries requires:
- Compliance with Live2D Proprietary Software License
- Appropriate licensing based on usage scale
- Proper attribution and license notices

IMPORTANT: The Live2D SDK is NOT included in this repository. Users must 
download it separately from Live2D Inc. and accept their license agreement.

REGARDING LIVE2D MODEL FILES IN THIS REPOSITORY:

This repository may include Live2D model files for demonstration purposes. 
If included, these are:
- Official free open-source models released by Live2D Inc.
- Available from Live2D's official sample model repository
- Subject to their respective open-source licenses (typically allowing free use)
- NOT custom models created by the Marionet project

Users who wish to use custom Live2D models must:
- Create or obtain their own models
- Ensure compliance with Live2D's model licensing terms
- Place model files in the resources/models/ directory

Official Resources:
- SDK Download: https://www.live2d.com/en/download/cubism-sdk/download-native/
- License Information: https://www.live2d.com/en/download/cubism-sdk/#license
- Contact: license@live2d.com

---

4.GODOT ENGINE
===

License: MIT License
Copyright: Godot Engine contributors
Website: https://godotengine.org/

Godot Engine is used as the runtime environment and is not included in this 
repository. Users must install Godot separately.

License details: https://godotengine.org/license

---

DISTRIBUTION GUIDELINES
===

DISTRIBUTING SOURCE CODE:

You may distribute the Marionet source code under the following conditions:

Permitted:
- Fork and modify the repository
- Share modifications under Apache 2.0
- Include in commercial projects (Marionet code only)
- Distribute without Live2D SDK or GDCubism binaries

Required:
- Include this LICENSE file
- Include NOTICE file (if provided)
- State changes made to the code
- Provide attribution to original authors
- Do NOT include Live2D SDK or compiled GDCubism binaries
- Instruct users to obtain these components separately

DISTRIBUTING COMPILED BINARIES:

WARNING: Compiled binaries that include GDCubism plugin linked with Live2D SDK 
are subject to Live2D's proprietary license.

Before distributing compiled binaries, you MUST:

1. Obtain appropriate Live2D Cubism SDK license
   - Free tier if revenue < $1M USD annually
   - Paid license for larger projects
   
2. Comply with Live2D license terms
   - Include required license notices
   - Provide proper attribution
   - Follow distribution restrictions
   
3. Include all required license files
   - This LICENSE file
   - Live2D license agreement
   - GDCubism MIT license notice
   
4. Clearly document the license status to end users

IMPORTANT: If you distribute binaries without obtaining proper Live2D 
licensing, you may be in violation of Live2D's proprietary software license.

ALTERNATIVE: DISTRIBUTING WITHOUT LIVE2D:

If you wish to distribute without Live2D licensing:
- Remove or replace the rendering component that uses GDCubism
- Use alternative rendering solutions
- Core framework functionality remains available under Apache 2.0
- The Marionet framework license (Apache 2.0) is unaffected by this choice

DEVELOPMENT AND BUILDING
===

FOR DEVELOPERS:

When building this project for personal use or testing:

Permitted without Live2D license:
- Clone this repository
- Compile with Live2D SDK for development
- Test and debug locally
- Modify the code for personal use
- Share modifications as source code

Not permitted without Live2D license:
- Distribute compiled binaries publicly
- Release on app stores
- Include in commercial products
- Deploy to public servers

COMPILATION REQUIREMENTS:

To build the complete project with rendering functionality:

1. Obtain Live2D Cubism SDK for Native
   - Download from: https://www.live2d.com/en/download/cubism-sdk/download-native/
   - Accept Live2D Open Software License for development
   
2. Compile GDCubism plugin
   - Follow instructions at: https://github.com/MizunagiKB/gd_cubism
   - Link with Live2D SDK
   - Output: Compiled plugin binaries (.dll, .so, .dylib)
   
3. Integrate plugin into Godot project
   - Place compiled binaries in addons/gd_cubism/bin/
   - Enable plugin in Godot project settings

IMPORTANT: This repository does NOT include compiled GDCubism plugin binaries.
Users must compile these themselves or obtain from authorized sources.

THIRD-PARTY DEPENDENCIES
===

This project may use additional third-party libraries and tools. Each has its 
own license terms:

- .NET SDK and Runtime: MIT License
- C# Language Libraries: Various (mostly MIT)
- Additional NuGet packages: See individual package licenses

Refer to project dependency files for complete list.

DISCLAIMER
===

This license document is provided for informational purposes. It does not 
constitute legal advice.

For authoritative license information, always refer to:
- Original Apache 2.0 License: https://www.apache.org/licenses/LICENSE-2.0
- Original MIT License: https://opensource.org/licenses/MIT  
- Official Live2D License: https://www.live2d.com/eula/

The maintainers of this project are not responsible for ensuring compliance 
with third-party licenses. Users are solely responsible for:
- Understanding all applicable license terms
- Obtaining necessary licenses before distribution
- Ensuring compliance with all legal requirements

When in doubt, consult a qualified legal professional.

CONTACT INFORMATION
===

Marionet Project:
- Repository: https://github.com/TLSLime/Marionet
- Issues: https://github.com/TLSLime/Marionet/issues
- Maintainers:
  * TLSLime: https://github.com/TLSLime
  * Forwindz: https://github.com/Forwindz

GDCubism Plugin:
- Repository: https://github.com/MizunagiKB/gd_cubism
- Author: MizunagiKB

Live2D Inc.:
- Website: https://www.live2d.com/
- Licensing: license@live2d.com
- Support: https://www.live2d.com/en/support/

ACKNOWLEDGMENTS
===

This project is developed and maintained by:
- TLSLime (https://github.com/TLSLime)
- Forwindz (https://github.com/Forwindz)

This project makes use of the following:
- Live2D Cubism SDK by Live2D Inc.
- GDCubism plugin by MizunagiKB
- Godot Engine by Godot Engine contributors
- Various open-source libraries and tools

We are grateful to all contributors and maintainers of these projects.


END OF LICENSE DOCUMENT
===