# README

## 開発環境

- Ruby 3.4.2
- Rails 8.0.2
- PostgreSQL 15

## 設計

### 既存サービスの足りてない所

- 長期インターンを取り扱っているのに学生の大学院進学を視野に入れていない
- 自己紹介等を書かせるのにエクセル等で出力できない（ユーザーの PC に保存できない）

-> 上記二つはかなり不満

### 仕様

DB は /docs/erd.plantuml を参考に

- authentication（認証機能）

  1. User の種類は {student , recuiter}
  2. student は /signup で登録できる
     リクエスト例：

  ```json
  {
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123",
      "role": "student"
    }
  }
  ```

  3.  company 最初の recuiter は company と一緒に登録できる
      リクエスト例

      ```json
      {
        "company": {
          "name": "Example Company",
          "email": "example@company.com",
          "industry_id": 1
        },
        "user": {
          "email": "recruiter@example.com",
          "password": "password123",
          "password_confirmation": "password123"
        },
        "recruiter": {
          "name": "John Recruiter"
        }
      }
      ```

  4.  二人目の recuiter からは recuiter の権利がある User しか生成できない
  5.  iv.の時に作成された recuiter は作成した recuiter と同一の company を持つ
