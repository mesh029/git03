export interface User {
  id: string;
  email: string;
  password_hash: string;
  name: string;
  phone?: string;
  is_admin: boolean;
  is_agent: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUserInput {
  email: string;
  password: string;
  name: string;
  phone?: string;
}

export interface UserResponse {
  id: string;
  email: string;
  name: string;
  phone?: string;
  is_admin: boolean;
  is_agent: boolean;
  created_at: Date;
  updated_at: Date;
}
