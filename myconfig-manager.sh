#!/usr/bin/env bash

# ตัวจัดการการตั้งค่า Dotfiles
# สคริปต์สำหรับจัดการการตั้งค่า dotfiles บนหลายแพลตฟอร์ม

# ตั้งค่าโหมดเข้มงวด (แต่ยอมให้คำสั่งส่งคืนค่า non-zero)
set -uo pipefail

# ค่าคงที่
CONFIG_DIR="$HOME/myconfig"
BACKUP_DIR="$HOME/myconfig-backup/$(date +%Y%m%d%H%M%S)"
LOG_FILE="$CONFIG_DIR/myconfig-manager.log"

# สีแบบ ANSI สำหรับการแสดงผลที่ดีขึ้น
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # ไม่มีสี

# รายการเครื่องมือทั้งหมด
ALL_TOOLS=(
  "wezterm" "tmux" "zsh" "oh-my-zsh" "powerlevel10k" 
  "yabai" "skhd" "karabiner" "sketchybar" "borders"
)

# เครื่องมือเฉพาะแพลตฟอร์ม
MAC_TOOLS=("yabai" "skhd" "karabiner" "sketchybar" "borders")
LINUX_TOOLS=()
WINDOWS_TOOLS=()
COMMON_TOOLS=("wezterm" "tmux" "zsh" "oh-my-zsh" "powerlevel10k")

# ฟังก์ชันสำหรับดึงพาธปลายทางของแต่ละเครื่องมือ
get_config_path() {
  local tool="$1"
  case "$tool" in
    wezterm)    echo "$HOME/.config/wezterm/wezterm.lua" ;;
    tmux)       echo "$HOME/.tmux.conf" ;;
    zsh)        echo "$HOME/.zshrc" ;;
    oh-my-zsh)  echo "$HOME/.oh-my-zsh/custom" ;;
    powerlevel10k) echo "$HOME/.p10k.zsh" ;;
    yabai)      echo "$HOME/.config/yabai/yabairc" ;;
    skhd)       echo "$HOME/.config/skhd/skhdrc" ;;
    karabiner)  echo "$HOME/.config/karabiner/karabiner.json" ;;
    sketchybar) echo "$HOME/.config/sketchybar/sketchybarrc" ;;
    borders)    echo "$HOME/.config/borders/bordersrc" ;;
    *)          echo "" ;;
  esac
}

# ฟังก์ชันสำหรับดึงพาธแหล่งที่มาจาก repo
get_source_path() {
  local tool="$1"
  case "$tool" in
    wezterm)    echo "$CONFIG_DIR/wezterm/wezterm.lua" ;;
    tmux)       echo "$CONFIG_DIR/tmux/tmux.conf" ;;
    zsh)        echo "$CONFIG_DIR/zsh/zshrc" ;;
    oh-my-zsh)  echo "$CONFIG_DIR/zsh/oh-my-zsh/custom" ;;
    powerlevel10k) echo "$CONFIG_DIR/zsh/powerlevel10k/p10k.zsh" ;;
    yabai)      echo "$CONFIG_DIR/mac/yabai/yabairc" ;;
    skhd)       echo "$CONFIG_DIR/mac/skhd/skhdrc" ;;
    karabiner)  echo "$CONFIG_DIR/mac/karabiner/karabiner.json" ;;
    sketchybar) echo "$CONFIG_DIR/mac/sketchybar/sketchybarrc" ;;
    borders)    echo "$CONFIG_DIR/mac/borders/bordersrc" ;;
    *)          echo "" ;;
  esac
}

# ฟังก์ชันสำหรับบันทึกข้อความ
log_message() {
  local level="$1"
  local message="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# ฟังก์ชันสำหรับแสดงข้อความสี
print_message() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${NC}"
  log_message "INFO" "$message"
}

# ฟังก์ชันสำหรับแสดงข้อความข้อผิดพลาด
print_error() {
  local message="$1"
  echo -e "${RED}ข้อผิดพลาด: ${message}${NC}" >&2
  log_message "ERROR" "$message"
}

# ฟังก์ชันสำหรับแสดงข้อความสำเร็จ
print_success() {
  local message="$1"
  echo -e "${GREEN}สำเร็จ: ${message}${NC}"
  log_message "SUCCESS" "$message"
}

# ฟังก์ชันสำหรับแสดงข้อความเตือน
print_warning() {
  local message="$1"
  echo -e "${YELLOW}คำเตือน: ${message}${NC}"
  log_message "WARNING" "$message"
}

# ฟังก์ชันสำหรับแสดงข้อความข้อมูล
print_info() {
  local message="$1"
  echo -e "${BLUE}ข้อมูล: ${message}${NC}"
  log_message "INFO" "$message"
}

# ฟังก์ชันสำหรับตรวจจับระบบปฏิบัติการ
detect_os() {
  case "$(uname -s)" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    *)        echo "unknown" ;;
  esac
}

# ฟังก์ชันสำหรับตรวจสอบว่าคำสั่งมีอยู่หรือไม่
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ฟังก์ชันสำหรับสร้างไดเรกทอรีหากไม่มีอยู่
ensure_dir_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    print_info "สร้างไดเรกทอรี: $dir"
  fi
}

# ฟังก์ชันสำหรับสำรองไฟล์การตั้งค่าที่มีอยู่
backup_config() {
  local config_path="$1"
  local tool_name="$2"

  # ตรวจสอบว่าไฟล์มีอยู่ และไม่ใช่ symlink
  if [[ -e "$config_path" && ! -L "$config_path" ]]; then
    ensure_dir_exists "$BACKUP_DIR/$tool_name"
    local backup_path="$BACKUP_DIR/$tool_name/$(basename "$config_path")"
    cp -R "$config_path" "$backup_path"
    print_info "สำรองการตั้งค่าดั้งเดิมสำหรับ $tool_name ไปยัง $backup_path"
    return 0  # สำรองสำเร็จ
  elif [[ -L "$config_path" ]]; then
    print_warning "พบ symlink ที่มีอยู่สำหรับ $tool_name ที่ $config_path"
    return 1  # พบ symlink ที่มีอยู่
  fi
  
  # ไฟล์ไม่มีอยู่ (ไม่จำเป็นต้องสำรอง)
  print_info "ไม่พบไฟล์การตั้งค่าที่มีอยู่สำหรับ $tool_name ที่ $config_path"
  return 0  # ไม่มีไฟล์ให้สำรอง แต่ไม่ใช่ข้อผิดพลาด
}

# ฟังก์ชันสำหรับคืนค่าการตั้งค่าจากการสำรอง
restore_config() {
  local config_path="$1"
  local tool_name="$2"
  
  # ค้นหาไดเรกทอรีสำรองล่าสุด
  local backup_dirs=("$HOME"/myconfig-backup/*)
  if [[ ${#backup_dirs[@]} -eq 0 || ! -d "${backup_dirs[0]}" ]]; then
    print_warning "ไม่พบการสำรองสำหรับ $tool_name"
    return 1
  fi
  
  # เรียงลำดับไดเรกทอรีสำรองจากใหม่ไปเก่า
  IFS=$'\n' backup_dirs=($(printf "%s\n" "${backup_dirs[@]}" | sort -r))
  
  # ค้นหาไฟล์สำรองล่าสุด
  for backup_dir in "${backup_dirs[@]}"; do
    local backup_file="$backup_dir/$tool_name/$(basename "$config_path")"
    if [[ -e "$backup_file" ]]; then
      # สร้างไดเรกทอรีปลายทางหากไม่มีอยู่
      ensure_dir_exists "$(dirname "$config_path")"
      # คืนค่าไฟล์
      cp -R "$backup_file" "$config_path"
      print_success "คืนค่าการตั้งค่าดั้งเดิมสำหรับ $tool_name จาก $backup_file"
      return 0
    fi
  done
  
  print_warning "ไม่พบการสำรองสำหรับ $tool_name ในไดเรกทอรีสำรองใดๆ"
  return 1
}

# ฟังก์ชันสำหรับสร้าง symlink
create_symlink() {
  local source="$1"
  local target="$2"
  local tool_name="$3"
  
  # สร้างไดเรกทอรีปลายทาง
  ensure_dir_exists "$(dirname "$target")"
  
  # สร้าง symlink
  ln -sf "$source" "$target"
  
  if [[ $? -eq 0 ]]; then
    print_success "สร้าง symlink สำหรับ $tool_name: $source -> $target"
    return 0
  else
    print_error "ล้มเหลวในการสร้าง symlink สำหรับ $tool_name"
    return 1
  fi
}

# ฟังก์ชันตรวจสอบการติดตั้งเครื่องมือ
check_tool_installed() {
  local tool="$1"
  case "$tool" in
    wezterm)    command_exists wezterm ;;
    tmux)       command_exists tmux ;;
    zsh)        command_exists zsh ;;
    oh-my-zsh)  [[ -d "$HOME/.oh-my-zsh" ]] ;;
    powerlevel10k) [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] ;;
    yabai)      command_exists yabai ;;
    skhd)       command_exists skhd ;;
    karabiner)  [[ -d "/Applications/Karabiner-Elements.app" ]] ;;
    sketchybar) command_exists sketchybar ;;
    borders)    command_exists borders ;;
    *)          return 1 ;;
  esac
}

# ฟังก์ชันติดตั้งการตั้งค่าเครื่องมือ
install_tool_config() {
  local tool="$1"
  
  print_info "กำลังติดตั้งการตั้งค่าสำหรับ $tool..."
  
  # ตรวจสอบว่าเครื่องมือติดตั้งแล้วหรือไม่
  if ! check_tool_installed "$tool"; then
    print_warning "$tool ไม่ได้ถูกติดตั้ง ข้ามการตั้งค่า"
    return 0  # ข้ามแต่ไม่ถือว่าล้มเหลว
  fi
  
  # ดึงพาธของไฟล์การตั้งค่า
  local config_path=$(get_config_path "$tool")
  local source_path=$(get_source_path "$tool")
  
  # ตรวจสอบว่าไฟล์แหล่งที่มามีอยู่
  if [[ ! -e "$source_path" ]]; then
    print_error "ไม่พบการตั้งค่าแหล่งที่มาสำหรับ $tool ที่ $source_path"
    return 1
  fi
  
  # สำรองไฟล์การตั้งค่าเดิม
  backup_config "$config_path" "$tool"
  local backup_status=$?
  
  # ถ้าพบ symlink ที่มีอยู่ ให้ถามว่าต้องการเขียนทับหรือไม่
  if [[ $backup_status -eq 1 ]]; then
    read -p "มี Symlink อยู่แล้วสำหรับ $tool คุณต้องการเขียนทับหรือไม่? (y/n): " answer
    if [[ "$answer" != "y" ]]; then
      print_info "ข้ามการตั้งค่า $tool"
      return 0
    fi
    rm -f "$config_path"
  fi
  
  # สร้าง symlink
  create_symlink "$source_path" "$config_path" "$tool"
  return $?
}

# ฟังก์ชันถอนการติดตั้ง
uninstall_tool_config() {
  local tool="$1"
  
  print_info "กำลังถอนการติดตั้งการตั้งค่าสำหรับ $tool..."
  
  local config_path=$(get_config_path "$tool")
  
  # ตรวจสอบว่ามี symlink หรือไม่
  if [[ -L "$config_path" ]]; then
    rm -f "$config_path"
    print_success "ลบ symlink สำหรับ $tool"
    # พยายามคืนค่าการตั้งค่าเดิม (แม้ว่าจะล้มเหลวก็ไม่เป็นไร)
    restore_config "$config_path" "$tool" || true
    return 0
  else
    print_warning "ไม่พบ symlink สำหรับ $tool ที่ $config_path"
    return 0  # ไม่พบ symlink แต่ไม่ถือว่าล้มเหลว
  fi
}

# ฟังก์ชันอัปเดตพื้นที่เก็บข้อมูล
update_repository() {
  print_info "กำลังอัปเดตพื้นที่เก็บข้อมูลการตั้งค่า..."
  
  if [[ ! -d "$CONFIG_DIR/.git" ]]; then
    print_error "$CONFIG_DIR ไม่ใช่พื้นที่เก็บข้อมูล git"
    return 1
  fi
  
  local current_dir=$(pwd)
  cd "$CONFIG_DIR" || { 
    print_error "ไม่สามารถเข้าถึงไดเรกทอรี $CONFIG_DIR"
    return 1
  }
  
  # ตรวจสอบการเปลี่ยนแปลงในท้องถิ่น
  if ! git diff --quiet; then
    print_warning "ตรวจพบการเปลี่ยนแปลงในท้องถิ่น กำลังเก็บการเปลี่ยนแปลง..."
    git stash || {
      print_error "ไม่สามารถเก็บการเปลี่ยนแปลงได้"
      cd "$current_dir"
      return 1
    }
  fi
  
  # ดึงการเปลี่ยนแปลงล่าสุดจากพื้นที่เก็บข้อมูลระยะไกล
  if git pull; then
    print_success "อัปเดตพื้นที่เก็บข้อมูลสำเร็จ"
  else
    print_error "ล้มเหลวในการอัปเดตพื้นที่เก็บข้อมูล"
    cd "$current_dir"
    return 1
  fi
  
  cd "$current_dir" || true
  return 0
}

# ฟังก์ชันติดตั้งทั้งหมด
install_all() {
  local os=$(detect_os)
  local tools=("${COMMON_TOOLS[@]}")
  local install_failed=0
  
  # เพิ่มเครื่องมือเฉพาะแพลตฟอร์ม
  case "$os" in
    macos) tools+=("${MAC_TOOLS[@]}") ;;
    linux) tools+=("${LINUX_TOOLS[@]}") ;;
  esac
  
  ensure_dir_exists "$BACKUP_DIR"
  
  # ติดตั้งเครื่องมือทั้งหมด
  for tool in "${tools[@]}"; do
    install_tool_config "$tool" || install_failed=1
  done
  
  if [[ $install_failed -eq 0 ]]; then
    print_success "การติดตั้งเสร็จสมบูรณ์!"
  else
    print_warning "การติดตั้งเสร็จสมบูรณ์ แต่มีบางเครื่องมือที่ล้มเหลว กรุณาตรวจสอบบันทึก"
  fi
  
  return $install_failed
}

# ฟังก์ชันถอนการติดตั้งทั้งหมด
uninstall_all() {
  local os=$(detect_os)
  local tools=("${COMMON_TOOLS[@]}")
  local uninstall_failed=0
  
  # เพิ่มเครื่องมือเฉพาะแพลตฟอร์ม
  case "$os" in
    macos) tools+=("${MAC_TOOLS[@]}") ;;
    linux) tools+=("${LINUX_TOOLS[@]}") ;;
  esac
  
  # ถอนการติดตั้งเครื่องมือทั้งหมด
  for tool in "${tools[@]}"; do
    uninstall_tool_config "$tool" || uninstall_failed=1
  done
  
  if [[ $uninstall_failed -eq 0 ]]; then
    print_success "การถอนการติดตั้งเสร็จสมบูรณ์!"
  else
    print_warning "การถอนการติดตั้งเสร็จสมบูรณ์ แต่มีบางเครื่องมือที่ล้มเหลว กรุณาตรวจสอบบันทึก"
  fi
  
  return $uninstall_failed
}

# ฟังก์ชันอัปเดตทั้งหมด
update_all() {
  if update_repository; then
    read -p "อัปเดตพื้นที่เก็บข้อมูลแล้ว คุณต้องการติดตั้งการตั้งค่าใหม่หรือไม่? (y/n): " answer
    [[ "$answer" == "y" ]] && install_all
    return 0
  else
    print_error "ล้มเหลวในการอัปเดตพื้นที่เก็บข้อมูล"
    return 1
  fi
}

# ฟังก์ชันติดตั้งเฉพาะเครื่องมือ
install_specific() {
  local tools=("$@")
  local install_failed=0
  
  ensure_dir_exists "$BACKUP_DIR"
  
  for tool in "${tools[@]}"; do
    if [[ " ${ALL_TOOLS[*]} " =~ " $tool " ]]; then
      install_tool_config "$tool" || install_failed=1
    else
      print_error "เครื่องมือที่ไม่รู้จัก: $tool"
      install_failed=1
    fi
  done
  
  return $install_failed
}

# ฟังก์ชันถอนการติดตั้งเฉพาะเครื่องมือ
uninstall_specific() {
  local tools=("$@")
  local uninstall_failed=0
  
  for tool in "${tools[@]}"; do
    if [[ " ${ALL_TOOLS[*]} " =~ " $tool " ]]; then
      uninstall_tool_config "$tool" || uninstall_failed=1
    else
      print_error "เครื่องมือที่ไม่รู้จัก: $tool"
      uninstall_failed=1
    fi
  done
  
  return $uninstall_failed
}

# ฟังก์ชันแสดงรายการเครื่องมือ
list_tools() {
  local os=$(detect_os)
  local all_tools=("${COMMON_TOOLS[@]}")
  
  case "$os" in
    macos) all_tools+=("${MAC_TOOLS[@]}") ;;
    linux) all_tools+=("${LINUX_TOOLS[@]}") ;;
  esac
  
  echo "เครื่องมือที่มี:"
  for tool in "${all_tools[@]}"; do
    local status="[ ]"
    if check_tool_installed "$tool"; then
      status="[✓]"
      # ตรวจสอบว่ามีการตั้งค่าแล้วหรือไม่
      if [[ -L "$(get_config_path "$tool")" ]]; then
        status="[✓*]"
      fi
    fi
    echo "  $status $tool"
  done
  
  echo
  echo "หมายเหตุ: [✓] = ติดตั้งแล้ว, [✓*] = ติดตั้งแล้วและตั้งค่าแล้ว, [ ] = ยังไม่ได้ติดตั้ง"
}

# ฟังก์ชันแสดงความช่วยเหลือ
show_help() {
  echo "ตัวจัดการการตั้งค่า Dotfiles"
  echo
  echo "การใช้งาน: $0 [คำสั่ง] [ตัวเลือก]"
  echo
  echo "คำสั่ง:"
  echo "  install                ติดตั้งการตั้งค่าทั้งหมด"
  echo "  install [tool1 tool2]  ติดตั้งเฉพาะเครื่องมือ"
  echo "  uninstall              ถอนการติดตั้งทั้งหมด"
  echo "  uninstall [tool1 tool2] ถอนการติดตั้งเฉพาะเครื่องมือ"
  echo "  update                 อัปเดตพื้นที่เก็บข้อมูล"
  echo "  list                   แสดงรายการเครื่องมือ"
  echo "  help                   แสดงความช่วยเหลือ"
  echo
  echo "ตัวอย่าง:"
  echo "  $0 install"
  echo "  $0 install tmux zsh"
  echo "  $0 uninstall"
  echo "  $0 update"
  echo
  list_tools
}

# ฟังก์ชันหลัก
main() {
  # ตรวจสอบว่ามีไดเรกทอรีการตั้งค่าหรือไม่
  if [[ ! -d "$CONFIG_DIR" ]]; then
    print_error "ไม่พบไดเรกทอรีการตั้งค่า: $CONFIG_DIR"
    print_info "กรุณาโคลนพื้นที่เก็บข้อมูลโดยใช้:"
    print_info "git clone https://github.com/memark0007/myconfig.git ~/myconfig"
    exit 1
  fi
  
  # สร้างไดเรกทอรีสำหรับไฟล์บันทึก
  ensure_dir_exists "$(dirname "$LOG_FILE")"
  
  # กำหนดคำสั่ง
  local command="${1:-help}"
  shift || true  # ป้องกันข้อผิดพลาดเมื่อไม่มีพารามิเตอร์
  
  # ประมวลผลคำสั่ง
  case "$command" in
    install)
      if [[ $# -eq 0 ]]; then install_all; else install_specific "$@"; fi
      ;;
    uninstall)
      if [[ $# -eq 0 ]]; then uninstall_all; else uninstall_specific "$@"; fi
      ;;
    update)    update_all ;;
    list)      list_tools ;;
    help)      show_help ;;
    *)
      print_error "คำสั่งไม่รู้จัก: $command"
      show_help
      exit 1
      ;;
  esac
}

# เรียกใช้ฟังก์ชันหลัก
main "$@"