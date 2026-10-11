#!/usr/bin/env bash
# ==============================================================================
# DevOps IT209 - Session 11 - Bài 4 (EX4)
# Khai báo GitHub Secrets và cấu hình Đăng nhập Container Registry (GHCR)
# Học viên: Nguyễn Quang Vinh (Vinh Nguyen)
# Repository: QuangVinh1605/IT209-SS11-CAU4
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

REPO="QuangVinh1605/IT209-SS11-CAU4"

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${GREEN}      DevOps IT209 - Session 11 - Bài 4 (EX4)                         ${NC}"
echo -e "${GREEN}   Khai báo GitHub Secrets & Cấu hình Đăng nhập Container Registry    ${NC}"
echo -e "${BLUE}=====================================================================${NC}\n"

# ------------------------------------------------------------------------------
# 1. Kiểm tra trạng thái Git và cấu hình Workflow
# ------------------------------------------------------------------------------
echo -e "${YELLOW}[BƯỚC 1] Kiểm tra file kịch bản CI...${NC}"
if [ -f ".github/workflows/ci.yml" ]; then
    echo -e "${GREEN}✓ Đã tìm thấy .github/workflows/ci.yml${NC}"
else
    echo -e "${RED}✗ Không tìm thấy file .github/workflows/ci.yml${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. Kiểm tra Repository Secret: REGISTRY_TOKEN
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[BƯỚC 2] Kiểm tra Repository Secret 'REGISTRY_TOKEN' trên GitHub...${NC}"
SECRET_CHECK=$(gh secret list -R "$REPO" 2>/dev/null | grep -w "REGISTRY_TOKEN" || true)

if [ -n "$SECRET_CHECK" ]; then
    echo -e "${GREEN}✓ Đã phát hiện Secret 'REGISTRY_TOKEN' trong repository $REPO!${NC}"
else
    echo -e "${RED}! Chưa tìm thấy Secret 'REGISTRY_TOKEN' trong repository $REPO.${NC}"
    echo -e "${CYAN}Vui lòng thực hiện theo hướng dẫn sau:${NC}"
    echo -e "  1. Tạo Personal Access Token (classic) với quyền 'write:packages':"
    echo -e "     -> https://github.com/settings/tokens"
    echo -e "  2. Thêm secret vào Repository:"
    echo -e "     -> https://github.com/$REPO/settings/secrets/actions"
    echo -e "     - Name: REGISTRY_TOKEN"
    echo -e "     - Secret: [Dán token ghp_... của bạn]"
    echo -e "  3. Chụp ảnh màn hình trang Repository Secrets làm minh chứng nộp bài."
    echo ""
    read -rp "Bạn đã cấu hình secret REGISTRY_TOKEN xong chưa? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
        echo -e "${YELLOW}Vui lòng hoàn tất cấu hình Secret trước khi tiếp tục.${NC}"
        exit 0
    fi
fi

# ------------------------------------------------------------------------------
# 3. Đẩy mã nguồn lên GitHub (git push)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[BƯỚC 3] Đẩy mã nguồn lên GitHub...${NC}"
git add .
git commit -m "feat: configure ghcr login workflow and homework report" || true
git push -u origin main
echo -e "${GREEN}✓ Đã đẩy mã nguồn lên nhánh main thành công!${NC}"

# ------------------------------------------------------------------------------
# 4. Theo dõi GitHub Actions Workflow
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[BƯỚC 4] Đang theo dõi GitHub Actions Workflow...${NC}"
sleep 3
RUN_ID=$(gh run list -R "$REPO" --limit 1 --json databaseId -q '.[0].databaseId')

if [ -n "$RUN_ID" ]; then
    echo -e "${CYAN}Đang theo dõi Workflow Run ID: $RUN_ID...${NC}"
    gh run watch "$RUN_ID" -R "$REPO" || true
    echo -e "\n${GREEN}[BƯỚC 5] Xem log chi tiết bước Đăng nhập Registry:${NC}"
    gh run view "$RUN_ID" -R "$REPO" --log | grep -E "Logging into|Login Succeeded|Registry" || gh run view "$RUN_ID" -R "$REPO"
else
    echo -e "${YELLOW}Vui lòng truy cập https://github.com/$REPO/actions để theo dõi trực tiếp.${NC}"
fi

echo -e "\n${BLUE}=====================================================================${NC}"
echo -e "${GREEN}               HOÀN THÀNH QUY TRÌNH KIỂM TRA BÀI 4                    ${NC}"
echo -e "${BLUE}=====================================================================${NC}"
