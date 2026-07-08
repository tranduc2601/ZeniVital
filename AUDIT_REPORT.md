# AUDIT_REPORT

## 1. Stack Thực Tế
- **Frontend**: Flutter
- **Backend/Database**: Không có backend thật, dùng `shared_preferences` qua lớp `LocalDatabase` (dạng key-value JSON local store).

## 2. Bug Dashboard "general_fitness kế hoạch"
- **Vị trí**: `lib/presentation/screens/main_tabs.dart`, hàm `_goalLabel(GoalType goal)`.
- **Nguyên nhân**: Hàm gọi `AppLocalizations.get('general_fitness')` cho mục tiêu `GoalType.conditioning`. Nhưng trong dictionary `lib/core/localization.dart` không có key `'general_fitness'`, mà chỉ có `'conditioning'`. Do đó nó fallback về chuỗi thô `'general_fitness'`. Sau đó UI ghép với `AppLocalizations.get('plan')` -> Thành "general_fitness Kế Hoạch".

## 3. Cấu trúc DB / Models liên quan
- **User**: `id, name, email, goal (GoalType enum)`
- **Exercise**: `id, name, targetMuscle, difficulty, equipment, imageUrl, gifUrl, description, isPremium, steps, images`
- **Routine / RoutineSlot**: Lưu lịch tập custom
- **WorkoutLog**: Lưu lịch sử tập
- **FeedPost**: Bài đăng cộng đồng

## 4. Dữ liệu Exercise & Các trường còn thiếu
- Các trường ĐÃ CÓ: `imageUrl`, `gifUrl` (đã được bổ sung trong bản vá trước qua CDN), `difficulty`, `targetMuscle`.
- Các trường ĐANG THIẾU: tag `goal` phù hợp, nhóm cơ/kiểu vận động chi tiết hơn, thời lượng ước tính, set/rep mặc định.
- **Trạng thái ảnh/GIF**: Toàn bộ 15 bài tập mẫu hiện tại đều ĐÃ CÓ `imageUrl` và `gifUrl` thông qua CDN `jsdelivr` và link `wikimedia`.

## 5. Tab Cộng Đồng (Community)
- **Nguồn dữ liệu mẫu**: Được hardcode trong `lib/data/api/static_data.dart` thông qua 2 biến tĩnh: `StaticData.personalFeed` và `StaticData.communityFeed`. Component `FeedScreen` trong `main_tabs.dart` sẽ render chúng chung với post local.

## 6. Bảng User & Dữ liệu sức khoẻ
- **Hiện tại**: Chỉ có `id, name, email, goal`.
- **Thiếu**: Chiều cao, cân nặng, tuổi, giới tính, mức độ kinh nghiệm, thời lượng mong muốn mỗi buổi. Bắt buộc phải cập nhật class `User` và `OnboardingScreen`.
