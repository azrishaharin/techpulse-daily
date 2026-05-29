import { defineCollection, z } from 'astro:content';

const articles = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    category: z.enum(['smartphone', 'gaming', 'ai']),
    source: z.string(),
    sourceUrl: z.string().url(),
    publishedAt: z.coerce.date(),
    author: z.string().default('Mochi for TechPulse'),
    image: z.string().optional(),
  }),
});

export const collections = { articles };