> 首次公开预发布版本（RC1）；独立工程的 Godot 编辑器运行验证仍在进行。

# PosePoint3D

一个独立的 **Godot 4 编辑器插件**，用于校准 3D 角色在椅子、床、柜台等动作标记处的位置和朝向，无需安装额外的 NPC 管理框架。

## 主要功能

- 自动列出场景内包含 `AnimationPlayer` 的 3D 角色。
- 创建 `PosePoint3DMarker` 动作标记。
- 在现有场景角色上预览选定动画，直接利用 Godot 3D 操作轴调整位置和旋转。
- 可选的地面吸附（地面碰撞层 1）。
- 将姿势偏移保存为 `.tres`，同一种家具可以通过 `template_key` 复用。
- 退出预览恢复角色原始位置与动画状态。
- 提供供运行时使用的定位辅助函数。

## 安装与使用

1. 将 `addons/posepoint3d` 文件夹放进项目的 `res://addons/`。
2. 在 **项目设置 → 插件** 中启用 **PosePoint3D**。
3. 打开并保存一个包含 3D 角色（带 `AnimationPlayer`）的场景。
4. 创建 `PosePoint3DMarker`，或点击 **Add marker at character**。
5. 在插件侧栏刷新场景，选择角色、动作点和动画。
6. 点击 **Begin calibration**，拖动和旋转角色，点击 **Save pose offset** 保存。

配置保存在 `res://posepoint3d_profiles/`。本仓库附带 `demo/demo.tscn` 作为独立演示场景。

## 注意

- 保存位置和旋转偏移，不保存缩放，不生成或重定向动作。
- 贴地吸附需要有效的地面碰撞体，且地面位于物理层 1。
- 同款家具可指定相同 `template_key`；角色名称或配置的 `posepoint_character_id` 是角色识别依据。
- 调整过程中不会自动写入资源，点击保存后才正式写入。
- 运行时示例与技术限制见英文 [README](README.md)。

许可证：MIT。欢迎提交真实的问题反馈和改进建议。
