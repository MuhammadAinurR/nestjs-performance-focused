import { Injectable } from '@nestjs/common';
import { createSigner } from 'fast-jwt';

// Very lightweight token service for maximal performance
@Injectable()
export class TokenService {
  private readonly signer: (payload: Record<string, any>) => string;
  private readonly expiresInSeconds: number;

  constructor() {
    const secret = process.env.JWT_SECRET || 'dev-secret-change-me';
    // parse expiration like '15m', '1h' or seconds number
    const rawExp = process.env.JWT_EXPIRES || '900s'; // default 15m
    this.expiresInSeconds = normalizeExpiry(rawExp);
    this.signer = createSigner({
      key: secret,
      expiresIn: this.expiresInSeconds,
      algorithm: 'HS256'
    });
  }

  signAccessToken(payload: Record<string, any>) {
    const iat = Math.floor(Date.now() / 1000);
  const token = this.signer({ ...payload, iat });
    return {
      token,
      token_type: 'Bearer',
      expires_in: this.expiresInSeconds,
      issued_at: iat
    };
  }
}

function normalizeExpiry(val: string): number {
  if (/^\d+$/.test(val)) return parseInt(val, 10);
  const match = val.match(/^(\d+)([smhd])$/);
  if (!match) return 900; // fallback 15m
  const num = parseInt(match[1], 10);
  const unit = match[2];
  switch (unit) {
    case 's': return num;
    case 'm': return num * 60;
    case 'h': return num * 3600;
    case 'd': return num * 86400;
    default: return 900;
  }
}
