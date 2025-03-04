# 📚 คู่มือการตั้งค่า My Config 🛠️

สวัสดี! มาเรียนรู้การจัดการ config ของเรากันเลย! ✨ 🎉

---

## 📌 วิธีใช้งานสคริปต์หลัก `myconfig-manager.sh`

### 1. ให้สิทธิ์รันสคริปต์
```bash
chmod +x myconfig-manager.sh
```

### 2. คำสั่งพื้นฐาน
| คำสั่ง                | การทำงาน                                      | ตัวอย่าง                 |
|-----------------------|-----------------------------------------------|--------------------------|
| `install`             | ติดตั้งการตั้งค่าทั้งหมด 🚀                  | `./myconfig-manager.sh install` |
| `install [ชื่อเครื่องมือ]` | ติดตั้งเฉพาะเครื่องมือ 🛠️           | `./myconfig-manager.sh install tmux zsh` |
| `uninstall`           | ถอนการติดตั้งทั้งหมด 🗑️                      | `./myconfig-manager.sh uninstall` |
| `update`              | อัปเดตการตั้งค่าจาก GitHub 🔄               | `./myconfig-manager.sh update` |
| `list`                | ดูรายการเครื่องมือทั้งหมด 📋                 | `./myconfig-manager.sh list` |
| `help`                | แสดงวิธีใช้ ℹ️                             | `./myconfig-manager.sh help` |

---

## 🧪 ทดสอบการทำงานสคริปต์

### 1. โหมด Debug (ดูขั้นตอนการทำงาน)
```bash
bash -x ./myconfig-manager.sh install
```

### 2. ตรวจสอบไฟล์ตั้งค่า
```bash
# ตัวอย่างตรวจสอบไฟล์ WezTerm
ls -l ~/.config/wezterm/wezterm.lua

# ตรวจสอบไฟล์อื่นๆ
ls -l ~/.tmux.conf
ls -l ~/.zshrc
ls -l ~/.p10k.zsh
ls -l ~/.config/yabai/yabairc
ls -l ~/.config/skhd/skhdrc
ls -l ~/.config/karabiner/karabiner.json
ls -l ~/.config/sketchybar/sketchybarrc
ls -l ~/.config/borders/bordersrc
```

---

## 🧩 ติดตั้งโปรแกรมเสริม (Submodules)

### ทำไมต้องใช้ Submodules?
ช่วยจัดการ Plugins ของ zsh เช่น การเติมคำอัตโนมัติ 🚨 หรือสีสันในคำสั่ง 🌈 ได้ง่ายขึ้น!

### คำสั่งสำคัญ
```bash
# ดึง Submodules เมื่อโคลน Repo ใหม่
git clone --recursive https://github.com/memark0007/myconfig.git

# หรือ Clone ใหม่พร้อม Submodules
git clone --recursive https://github.com/memark0007/myconfig.git

# อัปเดต Submodules
git submodule update --init --recursive

```

### อยากจัดการ Submodules เอง Ex.
```bash
# ดูรายการ Submodules ทั้งหมด
git submodule status

# ลบโฟลเดอร์ plugins เดิมที่คัดลอกมา (ถ้ามี)
rm -rf oh-my-zsh-custom/plugins/zsh-autosuggestions
rm -rf oh-my-zsh-custom/plugins/zsh-syntax-highlighting

# เพิ่ม plugins เป็น submodules
git submodule add https://github.com/zsh-users/zsh-autosuggestions zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions
git submodule add  https://github.com/zsh-users/zsh-syntax-highlighting zsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# เพิ่ม powerlevel10k theme เป็น submodule (ถ้าใช้)
git submodule add  https://github.com/romkatv/powerlevel10k.git zsh/oh-my-zsh/custom/themes/powerlevel10k

# ลบโฟลเดอร์ออกจาก Git Index (แต่ไม่ลบไฟล์จริง)
git rm --cached zsh/oh-my-zsh/custom/themes/powerlevel10k

```

---

## 📥 ดาวน์โหลดโปรแกรมหลัก

| โปรแกรม          | การทำงาน                            | ลิงก์ดาวน์โหลด 📥                          |
|------------------|-------------------------------------|--------------------------------------------|
| **WezTerm**      | เทอร์มินัลสวยๆ 💻                  | [GitHub](https://github.com/wez/wezterm)   |
| **tmux**         | แบ่งหน้าต่างเทอร์มินัล 🔲          | [GitHub](https://github.com/tmux/tmux)     |
| **zsh**          | เชลล์อัจฉริยะ 🐚                   | [GitHub](https://github.com/zsh-users/zsh) |
| **Oh My Zsh**    | ตกแต่ง zsh ให้สวยงาม ⭐            | [GitHub](https://github.com/ohmyzsh/ohmyzsh) |
| **Powerlevel10k**| ธีม Prompt เท่ๆ 🚀                 | [GitHub](https://github.com/romkatv/powerlevel10k) |
| **yabai**        | จัดหน้าต่างอัตโนมัติ macOS 🖥️      | [GitHub](https://github.com/koekeishiya/yabai) |
| **skhd**         | ตั้งค่า Shortcut คีย์บอร์ด ⌨️       | [GitHub](https://github.com/koekeishiya/skhd) |
| **Karabiner**    | ปรับแต่งปุ่มคีย์บอร์ด 🎹           | [GitHub](https://github.com/pqrs-org/Karabiner-Elements) |
| **SketchyBar**   | แถบเมนูสไตล์คุณ 🛠️                | [GitHub](https://github.com/FelixKratz/SketchyBarHelper) |
| **Borders**      | เพิ่มเส้นขอบหน้าต่าง 📏            | [GitHub](https://github.com/koekeishiya/borders) |

---

## 🚀 เคล็ดลับเพิ่มเติม

### หากพบปัญหา
- ลองรันคำสั่ง `./myconfig-manager.sh help` เพื่อดูวิธีใช้อีกครั้ง
- ตรวจสอบ Log ไฟล์ที่ `myconfig-manager.log`

### ต้องการช่วยพัฒนา?
- Fork Repo บน GitHub ของคุณเอง �
- ส่ง Pull Request เมื่อแก้ไขเสร็จ 📤

---

### สิ่งที่จะพัฒนาต่อไป?
- 🚀 มีตัวจัดการการติดตั้งโปรแกรมหลัก

---
🎉 **พร้อมแล้ว! เริ่มต้นการตั้งค่าได้เลย** 🎉  
หากมีคำถาม ติดต่อได้ที่ [GitHub Issues](https://github.com/memark0007/myconfig/issues)

