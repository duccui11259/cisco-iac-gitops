# KỊCH BẢN & NỘI DUNG TRÌNH CHIẾU BẢO VỆ ĐỒ ÁN TỐT NGHIỆP

> **Đề tài:** Xây dựng hệ thống tự động hóa cấu hình mạng (IaC) sử dụng mô hình GitOps kết hợp Ansible AWX cho thiết bị Cisco IOS  
> **Sinh viên thực hiện:** duccui11259  
> **Repository:** [https://github.com/duccui11259/cisco-iac-gitops.git](https://github.com/duccui11259/cisco-iac-gitops.git)  
> **Thời lượng dự kiến:** 15 phút (10 phút thuyết trình + 5 phút Live Demo)

---

## MỤC LỤC TRÌNH CHIẾU (11 SLIDES)

1. **Slide 1:** Trang bìa đề tài (Title Slide)
2. **Slide 2:** Đặt vấn đề & Thực trạng quản trị mạng truyền thống
3. **Slide 3:** Mục tiêu đề tài & Triết lý giải pháp (IaC & GitOps)
4. **Slide 4:** Tổng quan ngăn xếp công nghệ (Technology Stack)
5. **Slide 5:** Kiến trúc tổng thể hệ thống (System Architecture & Pipeline)
6. **Slide 6:** Thiết kế mã nguồn IaC & Cấu trúc vai trò (Roles)
7. **Slide 7:** Cơ chế định danh thiết bị & Tính lũy đẳng (Idempotency)
8. **Slide 8:** Kịch bản Demo thực tế (Live Demonstration)
9. **Slide 9:** Đánh giá kết quả & So sánh hiệu năng
10. **Slide 10:** Hướng phát triển & Khả năng mở rộng
11. **Slide 11:** Kết luận & Phiên thảo luận (Q&A)

---

## CHI TIẾT TỪNG SLIDE: NỘI DUNG CHIẾU & LỜI THOẠI TRÌNH BÀY

---

### SLIDE 1: TRANG BÌA ĐỀ TÀI

#### 1. Nội dung hiển thị trên màn hình:
```text
BỘ GIÁO DỤC VÀ ĐÀO TẠO - TRƯỜNG ĐẠI HỌC ...
KHOA CÔNG NGHỆ THÔNG TIN / ĐIỆN TỬ VIỄN THÔNG

BÁO CÁO ĐỒ ÁN TỐT NGHIỆP

ĐỀ TÀI:
XÂY DỰNG HỆ THỐNG TỰ ĐỘNG HÓA CẤU HÌNH MẠNG (IaC)
SỬ DỤNG MÔ HÌNH GITOPS KẾT HỢP ANSIBLE AWX CHO THIẾT BỊ CISCO IOS

• Sinh viên thực hiện : duccui11259
• Ngành              : Kỹ thuật Mạng / Truyền thông & Mạng máy tính
• Giảng viên hướng dẫn: ...
• Thời gian          : Năm học 2026
```

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Kính thưa các thầy cô trong Hội đồng chấm đồ án tốt nghiệp cùng toàn thể các bạn sinh viên có mặt trong buổi bảo vệ ngày hôm nay.*  
> *Lời đầu tiên, em xin gửi lời chào trân trọng và lời chúc sức khỏe tốt đẹp nhất tới quý thầy cô.*  
> *Hôm nay, em xin phép được báo cáo kết quả nghiên cứu và triển khai đồ án tốt nghiệp với đề tài: **'Xây dựng hệ thống tự động hóa cấu hình mạng (IaC) sử dụng mô hình GitOps kết hợp Ansible AWX cho thiết bị Cisco IOS'**. Sau đây em xin bắt đầu phần trình bày của mình."*

#### 3. Thao tác:
- Chiếu slide trang bìa, đứng ngay ngắn, giọng to rõ ràng, tự tin.

---

### SLIDE 2: ĐẶT VẤN ĐỀ & THỰC TRẠNG QUẢN TRỊ MẠNG TRUYỀN THỐNG

#### 1. Nội dung hiển thị trên màn hình:
- **Phương thức truyền thống (Manual CLI):**
  - Quản trị viên SSH/Telnet vào từng thiết bị bằng tay.
  - Gõ lệnh cấu hình trực tiếp trên giao diện dòng lệnh.
- **Hạn chế và rủi ro thực tế:**
  - ❌ **Sai sót con người (Human Error):** Chiếm tới 70-80% nguyên nhân gây sập mạng (Outage) do gõ nhầm IP, subnet, thiếu lệnh `no shutdown`.
  - ❌ **Tốn nhân lực & Chậm trễ:** Triển khai một thay đổi chính sách trên 50 thiết bị mất từ vài giờ đến vài ngày.
  - ❌ **Trôi dạt cấu hình (Configuration Drift):** Thiết bị thực tế bị thay đổi ngầm, không còn khớp với sơ đồ và tài liệu lưu trữ.
  - ❌ **Thiếu khả năng truy vết & Rollback:** Không rõ ai đã cấu hình gì, vào lúc nào; khi xảy ra sự cố không có phương án khôi phục tức thời.

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Thưa thầy cô, trong các trung tâm dữ liệu và doanh nghiệp hiện đại, quy mô mạng ngày càng phình to với hàng trăm thiết bị Router, Switch. Phương pháp quản trị mạng truyền thống hiện nay chủ yếu vẫn dựa vào việc kỹ sư SSH thủ công vào từng con để gõ lệnh.*  
> *Cách làm này bộc lộ những nhược điểm nghiêm trọng: Thứ nhất là rủi ro sai sót con người – chỉ cần một dấu chấm gõ nhầm ở subnet mask hay một dòng ACL đặt sai thứ tự là toàn bộ hệ thống có thể bị tê liệt. Thứ hai là mất rất nhiều thời gian, thiếu tính nhất quán và đặc biệt là hiện tượng 'trôi dạt cấu hình' khi kỹ sư sửa nóng ngoài giờ mà không cập nhật vào tài liệu. Khi xảy ra sự cố, việc truy vết ai đã sửa gì và làm sao để rollback lại trạng thái cũ là bài toán cực kỳ đau đầu."*

---

### SLIDE 3: MỤC TIÊU ĐỀ TÀI & TRIẾT LÝ GIẢI PHÁP (IaC & GITOPS)

#### 1. Nội dung hiển thị trên màn hình:
- **Cốt lõi giải pháp:**
  - **IaC (Infrastructure as Code):** Chuyển đổi toàn bộ cấu hình phần cứng mạng (IP, VLAN, OSPF, ACL) thành mã nguồn được định dạng bằng YAML/Jinja2.
  - **Khai báo mong muốn (Declarative Configuration):** Chỉ định nghĩa trạng thái mong muốn (*Desired State*), để hệ thống tự động đưa thiết bị về trạng thái đó.
  - **Mô hình GitOps:**
    - Git Repository đóng vai trò là **Nguồn chân lý duy nhất (Single Source of Truth)**.
    - Mọi thay đổi hạ tầng mạng đều bắt đầu từ một **Git Commit**.
    - Tự động kích hoạt luồng triển khai thông qua **Git Webhook** kết hợp máy chủ điều phối tập trung **Ansible AWX**.
- **Mục tiêu đạt được:**
  - Tự động hóa 100% quy trình cấp phát cấu hình (Zero-Touch Provisioning).
  - Tích hợp sẵn cơ chế kiểm soát phiên bản (Version Control), Audit Trail và Rollback chỉ trong vài giây.

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Để giải quyết triệt để bài toán trên, đồ án của em ứng dụng hai triết lý tiên tiến nhất của giới công nghệ hiện nay là **Infrastructure as Code (IaC)** và **GitOps**.*  
> *Thay vì gõ lệnh bằng tay, em biến toàn bộ cấu hình mạng thành các file mã nguồn. Toàn bộ thiết kế mạng được lưu trữ trên Git như một 'Nguồn chân lý duy nhất'. Khi người quản trị muốn thêm một VLAN hay sửa một dải IP, họ không chạm vào thiết bị mạng mà chỉ cần chỉnh sửa file code và thực hiện lệnh `git push`. Toàn bộ quá trình từ đồng bộ mã nguồn, kiểm tra, nạp cấu hình và báo cáo đều được thực hiện tự động bởi Ansible AWX."*

---

### SLIDE 4: TỔNG QUAN NGĂN XẾP CÔNG NGHỆ (TECH STACK)

#### 1. Nội dung hiển thị trên màn hình:
| Thành phần | Công nghệ lựa chọn | Vai trò trong hệ thống |
| :--- | :--- | :--- |
| **Mã nguồn & Version Control** | **GitHub** | Lưu trữ mã nguồn IaC, quản lý phiên bản commit, phát tín hiệu Webhook tự động |
| **Điều phối tự động hóa** | **Ansible AWX v24.6.1** | Bản nguồn mở của Red Hat Ansible Automation Platform: Quản trị Inventory, phân quyền RBAC, thực thi Job Runner |
| **Nền tảng vận hành AWX** | **Kubernetes K3s in WSL2** | Hệ thống Container Microservices gọn nhẹ, tự động co giãn Runner Pods |
| **Đường truyền Webhook** | **Cloudflare Tunnel** | Thiết lập đường hầm bảo mật HTTPS công khai từ Internet vào AWX nội bộ |
| **Cầu nối giao thức** | **Python SSH Bridge** | Chuyển đổi SSH an toàn từ AWX sang cổng Telnet Console của thiết bị mạng |
| **Thiết bị mạng thực thi** | **Cisco IOS (C7200 & C3725)** | Router L3 & Switch L2 NM-16ESW chạy Firmware nhị phân chính hãng trên GNS3 |

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Trên slide là toàn bộ ngăn xếp công nghệ em đã tích hợp trong đồ án. Trái tim của hệ thống là **Ansible AWX** phiên bản 24.6.1 – đây là nền tảng quản trị tự động hóa tiêu chuẩn doanh nghiệp của Red Hat. AWX được em triển khai dưới dạng kiến trúc Microservices chạy trên cụm Kubernetes K3s trong môi trường WSL2.*  
> *Đặc biệt, để kết nối linh hoạt giữa hạ tầng Cloud bên ngoài và thiết bị mạng giả lập bên trong máy tính, em đã lập trình một tiến trình **Python SSH Bridge** kết hợp với **Cloudflare Tunnel** giúp hệ thống tiếp nhận Webhook từ GitHub ở bất kỳ đâu trên thế giới và nạp cấu hình xuống thiết bị Cisco IOS an toàn."*

---

### SLIDE 5: KIẾN TRÚC TỔNG THỂ HỆ THỐNG & LUỒNG DỮ LIỆU

#### 1. Nội dung hiển thị trên màn hình:

```text
[ Kỹ sư mạng (NetOps) ] ──(Sửa file YAML)──► [ GitHub Repository ]
                                                    │
                                        (Push Event / Webhook JSON)
                                                    ▼
                                          [ Cloudflare Tunnel ]
                                                    │
                                          (Chuyển tiếp Webhook)
                                                    ▼
                                          [ Ansible AWX (K3s) ]
                                                    │
                                         (Cấp phát Runner Pod EE)
                                                    ▼
                                    [ SSH Bridge (Port 2221, 2222) ]
                                                    │
                                           (Telnet 5000, 5003)
                                                    ▼
                                    [ Thiết bị mạng Cisco IOS GNS3 ]
                                    (Router-Edge & Switch-Access)
```

- **Quy trình luồng dữ liệu 5 bước:**
  1. NetOps commit thay đổi cấu hình lên nhánh `main` của GitHub.
  2. GitHub gửi payload Webhook qua Internet tới Cloudflare Tunnel.
  3. AWX tiếp nhận Webhook, tự động cập nhật Project SCM mới nhất.
  4. Kubernetes cấp phát một Runner Pod riêng biệt (`awx-ee`) chứa Ansible và module `cisco.ios`.
  5. Runner Pod kết nối SSH qua Bridge để đẩy các câu lệnh cấu hình xuống thiết bị Cisco.

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Thưa thầy cô, đây là sơ đồ kiến trúc tổng thể của hệ thống. Luồng vận hành diễn ra hoàn toàn khép kín và tự động:*  
> *Đầu tiên, người quản trị chỉ cần thực hiện `git push` lên GitHub. Ngay lập tức, GitHub bắn một gói tin Webhook qua đường hầm Cloudflare Tunnel để đánh thức AWX. AWX sẽ đồng bộ code mới nhất từ GitHub và ra lệnh cho Kubernetes sinh ra một Runner Pod độc lập mang tên `awx-ee`. Runner Pod này mang đầy đủ thư viện `cisco.ios`, thiết lập phiên SSH tới các thiết bị mạng Cisco thông qua tiến trình SSH Bridge và đẩy cấu hình xuống. Toàn bộ chu trình này diễn ra chỉ trong vòng chưa đầy 45 giây mà không cần sự can thiệp thủ công của con người."*

---

### SLIDE 6: THIẾT KẾ MÃ NGUỒN IaC & CẤU TRÚC VAI TRÒ (ROLES)

#### 1. Nội dung hiển thị trên màn hình:
- **Cấu trúc phân tách Dữ liệu (Data) và Logic (Execution):**
  - **Thư mục Dữ liệu (`group_vars/` và `host_vars/`):** Nơi kỹ sư khai báo thông số mạng mà không cần biết lập trình (IP, VLAN ID, tên phòng ban, dải ACL).
  - **Thư mục Logic (`roles/`):** Chứa các tác vụ Ansible nạp cấu hình chuẩn hóa:
    - 📁 `roles/base`: Đồng bộ Hostname, Banner MOTD, bảo mật SSH Line VTY, Hardening.
    - 📁 `roles/interfaces`: Cấu hình IP cổng mạng L3, cấu hình cổng Access/Trunk L2, Static Routes.
    - 📁 `roles/vlans`: Đồng bộ cơ sở dữ liệu VLAN phòng ban cho Switch.
    - 📁 `roles/routing`: Cấu hình giao thức định tuyến động OSPF Area 0, Router-ID.
    - 📁 `roles/acls`: Khởi tạo Extended Access Control List kiểm soát an ninh mạng.
    - 📁 `roles/services`: Cấu hình đồng bộ thời gian NTP và đẩy nhật ký giám sát Syslog.

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Về mặt kiến trúc phần mềm, em áp dụng nguyên lý tách biệt hoàn toàn giữa **Dữ liệu cấu hình** và **Logic thực thi**.  
> Người quản trị mạng chỉ cần làm việc với các file YAML đơn giản trong `group_vars` và `host_vars` để khai báo địa chỉ IP hay tên VLAN.  
> Còn phần xử lý kỹ thuật phức tạp được chia thành 6 Role độc lập gồm: Base, Interfaces, VLANs, Routing, ACLs và Services. Thiết kế dạng module này giúp hệ thống cực kỳ dễ mở rộng: khi doanh nghiệp bổ sung thêm 10 hay 100 con Switch mới, ta chỉ cần thêm file biến mà không cần phải viết lại Playbook."*

---

### SLIDE 7: CƠ CHẾ ĐỊNH DANH THIẾT BỊ & TÍNH LŨY ĐẲNG (IDEMPOTENCY)

#### 1. Nội dung hiển thị trên màn hình:
- **1. Cơ chế định danh (Device Identification):**
  - Tên file `host_vars/<hostname>.yml` khớp chính xác 100% với tên thiết bị trong Inventory.
  - Phân biệt giữa các thiết bị bằng cặp **IP + Port kết nối**:
    - `router-edge`: Cổng SSH `2221` ──► Console Telnet `5000` (R1)
    - `switch-access`: Cổng SSH `2222` ──► Console Telnet `5003` (R3)
- **2. Tính Lũy Đẳng (Idempotency - Điểm sáng kỹ thuật):**
  - Khác với script gõ lệnh tuần tự (luôn ghi đè mù quáng), Ansible thực hiện:
    $$\text{Trạng thái hiện tại (Current State)} \longleftrightarrow \text{Trạng thái mong muốn (Desired State)}$$
  - **Chỉ nạp phần cấu hình còn thiếu (`changed`)**.
  - Nếu cấu hình trên thiết bị đã khớp với code trong Git: **Ansible bỏ qua (`ok`), không gửi lệnh thừa**.
  - **Lợi ích:** Không làm chớp cổng (flapping), không gây gián đoạn đường truyền, loại bỏ hoàn toàn nguy cơ mất kết nối mạng.

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Một câu hỏi rất quan trọng là: Làm sao hệ thống biết đâu là Router biên và đâu là Switch truy cập? Em xin trả lời: Hệ thống phân biệt dựa trên cơ chế ánh xạ giữa tên định danh trong Inventory và số hiệu cổng kết nối của từng thiết bị.  
> Đặc biệt, điểm sáng kỹ thuật lớn nhất của đồ án này chính là **Tính Lũy Đẳng (Idempotency)**. Nếu chúng ta dùng script Python thông thường, mỗi lần chạy nó lại gõ lại toàn bộ lệnh từ đầu, rất dễ gây chớp cổng mạng hoặc ngắt kết nối phiên làm việc của người dùng. Còn với Ansible, hệ thống sẽ tự đối chiếu trạng thái thực tế với code khai báo: cái gì đã có rồi thì giữ nguyên, chỉ bổ sung đúng cái còn thiếu. Nếu chạy lại lần 2 mà code không đổi, hệ thống sẽ báo `changed=0`, đảm bảo độ ổn định 100% cho mạng doanh nghiệp."*

---

### SLIDE 8: KỊCH BẢN LIVE DEMO TRỰC TIẾP TRƯỚC HỘI ĐỒNG

#### 1. Nội dung hiển thị trên màn hình:
- **Kịch bản Demo gồm 3 phần:**
  1. **Kiểm tra trạng thái ban đầu:** Switch chỉ có VLAN 10, 20, 30.
  2. **Thao tác GitOps:** Thêm VLAN 50 (Marketing) vào file `group_vars/switches.yml` và chạy:
     ```bash
     git commit -am "feat: bo sung vlan 50 marketing"
     git push origin main
     ```
  3. **Quan sát tự động hóa:**
     - GitHub kích hoạt Webhook -> AWX nhận tín hiệu và tự chạy Job.
     - Kiểm tra trực tiếp trên console Switch Cisco: Gõ `show vlan-switch brief` -> VLAN 50 xuất hiện tức thì!
  4. **Kiểm chứng Tính Lũy Đẳng:** Chạy lại chính Job đó -> Kết quả `changed=0`.

#### 2. Lời thoại trình bày & Thao tác thực tế (Speaker Notes & Live Action):
> *(Chuyển sang màn hình thao tác thực tế)*  
> *"Sau đây, em xin phép được trình diễn tính năng Live Demo thực tế của hệ thống.*  
> - **Bước 1:** Em mở màn hình Console của Switch Cisco trên GNS3, gõ lệnh `show vlan-switch brief`. Thầy cô có thể thấy hiện tại Switch chỉ có 3 VLAN là 10, 20 và 30.  
> - **Bước 2:** Giả sử phòng ban Marketing cần cấp một VLAN 50 mới. Em mở file `group_vars/switches.yml`, thêm khai báo VLAN 50.  
> - **Bước 3:** Em mở terminal gõ `git commit` và `git push`. Em xin khẳng định là em không hề chạm vào màn hình console của Cisco hay bấm bất kỳ nút nào trên giao diện AWX.  
> - **Bước 4:** Thầy cô nhìn sang màn hình AWX: Webhook từ GitHub đã tự động đánh thức AWX, Job số 31 đang tự chạy trong Runner Pod.  
> - **Bước 5:** Job hoàn thành xanh lá! Em quay lại màn hình Console của Switch, gõ lại `show vlan-switch brief`: **VLAN 50 (Marketing) đã hiện diện ngay lập tức!**  
> - **Bước 6:** Bây giờ em bấm chạy lại Job này lần nữa trên AWX: Kết quả trả về `changed=0`, minh chứng trọn vẹn cho tính lũy đẳng của hệ thống."*

---

### SLIDE 9: ĐÁNH GIÁ KẾT QUẢ & SO SÁNH HIỆU NĂNG

#### 1. Nội dung hiển thị trên màn hình:
| Tiêu chí so sánh | Quản trị mạng thủ công (CLI) | Hệ thống GitOps + AWX (Đồ án) |
| :--- | :--- | :--- |
| **Thời gian triển khai** | 30 - 60 phút / 10 thiết bị | **< 45 giây cho toàn bộ mạng** |
| **Tỷ lệ sai sót cấu hình** | Cao (Do nhầm lẫn gõ phím) | **0% (Nhất quán tuyệt đối theo code)** |
| **Lịch sử & Truy vết (Audit)** | Không có hoặc phụ thuộc ghi chép | **Đầy đủ 100% qua lịch sử Git Commit & AWX Job Log** |
| **Khả năng Rollback sự cố** | Khó khăn, mất nhiều giờ sửa tay | **Tức thời chỉ bằng lệnh `git revert` (< 30 giây)** |
| **Bảo mật tài khoản mạng** | Kỹ sư biết mật khẩu trực tiếp | **Mã hóa tập trung qua AWX Credential Vault & RBAC** |
| **Mức độ phụ thuộc con người**| Rất cao, phụ thuộc kỹ sư cứng | **Tự động hóa hoàn toàn theo chuẩn DevOps** |

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Thưa Hội đồng, bảng so sánh trên slide là kết quả định lượng cụ thể mà đồ án đã đạt được.  
> Thời gian cấu hình được rút ngắn từ hàng giờ đồng hồ xuống chỉ còn dưới 45 giây. Tỷ lệ sai sót giảm về mức 0% nhờ tính nhất quán của mã nguồn. Toàn bộ lịch sử ai đã sửa gì đều được ghi nhận minh bạch trên Git và AWX Audit Log. Và quan trọng nhất, khi xảy ra sự cố khẩn cấp, chúng ta có thể rollback toàn bộ hệ thống mạng trở về trạng thái ổn định chỉ bằng một thao tác `git revert` mà không cần phải thức trắng đêm để cứu mạng."*

---

### SLIDE 10: HƯỚNG PHÁT TRIỂN & KHẢ NĂNG MỞ RỘNG

#### 1. Nội dung hiển thị trên màn hình:
- **1. Hỗ trợ đa nhà sản xuất (Multi-Vendor Network):**
  - Mở rộng thêm các Collection cho **Juniper Junos**, **Arista EOS**, **Fortinet FortiOS** và **MikroTik RouterOS**.
- **2. Tích hợp đường ống kiểm thử tự động (CI/CD Network Testing Pipeline):**
  - Áp dụng **Batfish** hoặc **PyATS (Cisco Test Automation)** để mô phỏng và kiểm tra luồng định tuyến, bảo mật trước khi cho phép Merge code vào nhánh `main`.
- **3. Giám sát tự động hóa & Tự phục hồi (Telemetry & Self-Healing Network):**
  - Tích hợp Streaming Telemetry, Prometheus & Grafana để phát hiện bất thường và tự động kích hoạt Playbook khôi phục cấu hình khi có hiện tượng trôi dạt (Configuration Drift Detection).

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Trong tương lai, đồ án có thể tiếp tục phát triển theo 3 hướng mở rộng lớn:  
> Thứ nhất là mở rộng hỗ trợ môi trường mạng đa hãng gồm Juniper, Fortinet và Mikrotik nhờ kiến trúc cắm rút linh hoạt của Ansible.  
> Thứ hai là tích hợp đường ống CI/CD với công cụ Batfish để kiểm tra lỗi cú pháp và mô phỏng luồng dữ liệu trước khi nạp xuống mạng thật, đạt chuẩn Network DevSecOps.  
> Và thứ ba là kết hợp với các giải pháp giám sát như Prometheus/Grafana để tạo ra mạng có khả năng tự phát hiện trôi dạt cấu hình và tự động phục hồi (Self-Healing Network)."*

---

### SLIDE 11: KẾT LUẬN & PHIÊN HỎI ĐÁP (Q&A)

#### 1. Nội dung hiển thị trên màn hình:
```text
KẾT LUẬN

✔ Xây dựng thành công hệ thống tự động hóa cấu hình mạng IaC theo mô hình GitOps.
✔ Làm chủ công nghệ điều phối Ansible AWX trên nền tảng Microservices Kubernetes K3s.
✔ Đã kiểm thử và chạy thực tế thành công 100% trên các thiết bị mạng Cisco IOS (L2 & L3).
✔ Đáp ứng đầy đủ các tiêu chuẩn: Nhanh chóng, Nhất quán, Có khả năng Rollback và Tính lũy đẳng cao.

EM XIN CHÂN THÀNH CẢM ƠN QUÝ THẦY CÔ VÀ HỘI ĐỒNG ĐÃ LẮNG NGHE!
Kính mời quý thầy cô đặt câu hỏi thảo luận (Q&A).
```

#### 2. Lời thoại trình bày (Speaker Notes):
> *"Kính thưa quý thầy cô trong Hội đồng, đồ án đã hoàn thành đầy đủ các mục tiêu đề ra ban đầu, xây dựng thành công một hệ thống tự động hóa cấu hình mạng GitOps hoàn chỉnh, ổn định và sẵn sàng áp dụng vào thực tế doanh nghiệp.  
> Em xin chân thành cảm ơn các thầy cô trong Hội đồng đã chú ý lắng nghe bài báo cáo của em. Em rất mong nhận được những nhận xét, góp ý quý báu của quý thầy cô để đồ án được hoàn thiện hơn nữa.  
> Em xin trân trọng kính mời quý thầy cô đặt câu hỏi ạ!"*
